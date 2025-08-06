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
resource "aws_subnet" "private_app" {
  for_each = { for i, cidr in var.private_app_subnet_cidrs : i => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[each.key]

  tags = {
    Name = "teammjk-private-app-subnet-${each.key + 1}"
  }
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "teammjk-private-app-rt"
  }
}

resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app.id
}


# ====================================================================================
# Private Subnets - Database
# ====================================================================================
resource "aws_subnet" "private_db" {
  for_each = { for i, cidr in var.private_db_subnet_cidrs : i => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[each.key]

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
# VPC Endpoint
# ====================================================================================

resource "aws_security_group" "vpc_endpoint" {
  name        = "teammjk-vpc-endpoint-sg"
  description = "Allow TLS inbound traffic for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from anywhere in the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "teammjk-vpc-endpoint-sg"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.private_app.id, aws_route_table.private_db.id]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [for s in aws_subnet.private_app : s.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  tags = {
    Name = "teammjk-ecr-api-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [for s in aws_subnet.private_app : s.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  tags = {
    Name = "teammjk-ecr-dkr-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "codedeploy" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.codedeploy"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [for s in aws_subnet.private_app : s.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  tags = {
    Name = "teammjk-codedeploy-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [for s in aws_subnet.private_app : s.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  tags = {
    Name = "teammjk-secretsmanager-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [for s in aws_subnet.private_app : s.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  tags = {
    Name = "teammjk-logs-vpc-endpoint"
  }
}
