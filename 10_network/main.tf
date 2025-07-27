resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
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

# Public Subnets, NAT Gateways, and Routing
resource "aws_subnet" "public" {
  for_each = { for i, cidr in var.public_subnet_cidrs : i => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = var.availability_zones[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "teammjk-public-subnet-${each.key + 1}"
  }
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"
  tags = {
    Name = "teammjk-nat-eip-${each.key + 1}"
  }
}

resource "aws_nat_gateway" "main" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "teammjk-nat-gateway-${each.key + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "teammjk-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private App Subnets and Routing
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
  for_each = aws_nat_gateway.main

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "teammjk-private-app-rt-${each.key + 1}"
  }
}

resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app[each.key].id
}

# Private DB Subnets and Routing
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
