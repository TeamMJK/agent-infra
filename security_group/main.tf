resource "aws_security_group" "agent_sg" {
  name   = "teammjk-agent-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_ip] # SSH 허용 대역
  }

  ingress {
    from_port   = 8000 # Agent Port
    to_port     = 8000
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

resource "aws_security_group" "backend_sg" {
  name   = "teammjk-backend-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_ip]
  }

  ingress {
    from_port   = 8080 # Spring Boot Port
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id, aws_security_group.agent_sg.id] # ALB SG와 Agent SG에서 오는 트래픽 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "teammjk-db-sg"
  description = "Allow Postgres access from application servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres access from app & agent"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.agent_sg.id, aws_security_group.backend_sg.id] # 앱서버 SG ID 참조
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

resource "aws_security_group" "elasticache_sg" {
  name        = "teammjk-elasticache-sg"
  description = "Allow Redis access from backend server"
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