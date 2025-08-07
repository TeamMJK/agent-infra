# =========================================
# Agent Server Security Group
# =========================================
resource "aws_security_group" "agent_sg" {
  name   = "teammjk-agent-sg"
  vpc_id = var.vpc_id

  # SSH 접근 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_ip]
    description = "SSH access from allowed IP"
  }

  # Agent 서비스 포트 (외부 접근 가능)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Agent service port"
  }

  # SpringBoot 서버로부터의 인바운드 허용 (Agent 서비스)
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
    description     = "Allow SpringBoot to Agent communication"
  }

  # 외부로 모든 통신 허용 (IGW 경유)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "teammjk-agent-sg"
  }
}


# =========================================
# ALB Security Group
# =========================================
resource "aws_security_group" "alb_sg" {
  name   = "teammjk-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# =========================================
# SpringBoot Server Security Group
# =========================================
resource "aws_security_group" "backend_sg" {
  name   = "teammjk-backend-sg"
  vpc_id = var.vpc_id

  # ALB로부터 API 통신 수신
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow ALB to SpringBoot communication"
  }

  # 모든 아웃바운드 트래픽 허용 (명시적 표현을 위해 선언...)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "teammjk-backend-sg"
  }
}


# =========================================
# Database Security Group
# =========================================
resource "aws_security_group" "db_sg" {
  name        = "teammjk-db-sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres access <- SpringBoot server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "teammjk-db-sg"
    Team = "infra"
  }
}


# =========================================
# ElastiCache Security Group
# =========================================
resource "aws_security_group" "elasticache_sg" {
  name        = "teammjk-elasticache-sg"
  description = "Allow Redis access <- SpringBoot server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis access from backend"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "teammjk-elasticache-sg"
  }
}