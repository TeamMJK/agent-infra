# 1) DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "teammjk-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "RDS Private Subnet Group for teammjk"
}

# 2) DB 전용 Security Group
resource "aws_security_group" "db_sg" {
  name        = "teammjk-db-sg"
  description = "Allow Postgres access from application servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres access from app & agent"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.app_sg_ids # 앱서버 SG ID 참조
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

# 3) RDS 인스턴스
resource "aws_db_instance" "db" {
  identifier        = "teammjk-app-db"
  engine            = "postgres"    # Postgres 엔진 
  instance_class    = "db.t3.micro" # Free Tier 인스턴스
  allocated_storage = 10            # Free Tier 범위 (최대10GB)
  db_name           = "teammjkdb"   # 생성할 DB 이름
  username          = "masteruser"  # 5단계에서 생성된 DB 시크릿 연동
  password          = var.db_password
  port              = 5432

  # 네트워크
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name # Subnet Group 연결
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # 보안: 비공개 접근만 허용
  publicly_accessible = false # public 접근 차단

  # 스토리지 암호화
  storage_encrypted = true                    # 데이터 at rest 암호화 
  kms_key_id        = var.kms_key_arn # 5단계 생성한 CMK 사용 

  # 가용성 & 백업
  multi_az                = false # 비용 절감용 단일 AZ
  backup_retention_period = 7     # 7일 간의 자동 백업 보관
  skip_final_snapshot     = true  # 최종 스냅샷 생략

  tags = {
    Name = "teammjk-app-db"
    Team = "infra"
  }
}
