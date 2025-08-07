resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "teammjk-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "teammjk-igw"
  }
}

# ====================================================================================
# Public Subnets - Agent
# ====================================================================================
resource "aws_subnet" "public_agent" {
  for_each = { for i, cidr in var.public_agent_subnet_cidrs : i => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = var.availability_zones[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "teammjk-public-agent-subnet-${each.key + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "teammjk-public-agent-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public_agent

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


# ====================================================================================
# Private Subnets - Spring Boot
# ====================================================================================
resource "aws_subnet" "private_backend" {
  for_each = { for i, cidr in var.private_backend_subnet_cidrs : i => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[each.key]

  tags = {
    Name = "teammjk-private-app-subnet-${each.key + 1}"
  }
}

resource "aws_route_table" "private_backend" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "teammjk-private-app-rt"
  }
}

resource "aws_route_table_association" "private_backend" {
  for_each = aws_subnet.private_backend

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_backend.id
}


# ====================================================================================
# Private Subnets - Database
# ====================================================================================
resource "aws_subnet" "private_db" {
  for_each = { for i, cidr in var.private_db_subnet_cidrs : i => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  # Single AZ 설정 [single-az-refactor]
  # 같은 AZ 내에서도 가능. 비용 절감을 위해 모든 DB 서브넷을 동일한 AZ에 배치
  availability_zone = var.availability_zones[0] # [single-az-refactor] 항상 첫 번째 AZ 사용

  tags = {
    Name = "teammjk-private-db-subnet-${each.key + 1}"
  }
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "teammjk-private-db-rt"
  }
}

resource "aws_route_table_association" "private_db" {
  for_each = aws_subnet.private_db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db.id
}


# ====================================================================================
# NAT Gateway (단일 AZ - 비용절감)
# ====================================================================================

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "teammjk-nat-eip"
  }
}

# NAT Gateway (첫 번째 Public Subnet에만 배치)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public_agent)[0].id

  tags = {
    Name = "teammjk-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}

# ====================================================================================
# VPC Endpoint - S3만 유지 (Gateway, 무료)
# ====================================================================================

# S3 Gateway Endpoint - 무료이며 S3 접근 최적화를 위해 유지
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.private_backend.id, aws_route_table.private_db.id]
  
  tags = {
    Name = "teammjk-s3-vpc-endpoint"
  }
}
