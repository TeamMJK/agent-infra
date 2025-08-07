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
# VPC Endpoint
# ====================================================================================

# VPC Endpoint 설정 표준화를 위한 로컬 변수
locals {
  # Interface VPC Endpoints 설정
  interface_vpc_endpoints = {
    ecr_api        = "ecr.api"
    ecr_dkr        = "ecr.dkr"
    codedeploy     = "codedeploy"
    secretsmanager = "secretsmanager"
    ssm            = "ssm"
    ssm_messages   = "ssmmessages"
    ec2_messages   = "ec2messages"
  }
  
  # 공통 VPC Endpoint 설정
  common_vpc_endpoint_config = {
    vpc_endpoint_type   = "Interface"
    private_dns_enabled = true
    subnet_ids          = [for s in aws_subnet.private_backend : s.id]
    security_group_ids  = [aws_security_group.vpc_endpoint.id]
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "teammjk-vpc-endpoint-sg"
  description = "Security group for all VPC endpoints (ECR, CodeDeploy, Secrets Manager, SSM)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC for all VPC endpoint communication"
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
  route_table_ids = [aws_route_table.private_backend.id, aws_route_table.private_db.id]
}

# Interface VPC Endpoints - 표준화된 설정으로 생성
resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each = local.interface_vpc_endpoints

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = local.common_vpc_endpoint_config.vpc_endpoint_type
  private_dns_enabled = local.common_vpc_endpoint_config.private_dns_enabled

  subnet_ids         = local.common_vpc_endpoint_config.subnet_ids
  security_group_ids = local.common_vpc_endpoint_config.security_group_ids

  tags = {
    Name = "teammjk-${each.key}-vpc-endpoint"
  }
}
