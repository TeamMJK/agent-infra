# 1) DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "teammjk-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "RDS Private Subnet Group for teammjk"
}

# 2) RDS 인스턴스
resource "aws_db_instance" "db" {
  identifier        = "teammjk-app-db"
  engine            = "postgres"    # Postgres 엔진 
  instance_class    = "db.t3.micro" # Free Tier 인스턴스
  allocated_storage = 20            # Free Tier 범위 (최대20GB)
  db_name           = "teammjkdb"   # 생성할 DB 이름
  username          = "masteruser"  # 5단계에서 생성된 DB 시크릿 연동
  password          = var.db_password
  port              = 5432

  # 네트워크
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name # Subnet Group 연결
  vpc_security_group_ids = [var.db_sg_id]

  # 보안: 비공개 접근만 허용
  publicly_accessible = false # public 접근 차단

  # 스토리지 암호화
  storage_encrypted = true                    # 데이터 at rest 암호화 
  kms_key_id        = var.kms_key_arn # 5단계 생성한 CMK 사용 

  # 가용성 & 백업
  multi_az                = false # [test] 비용 절감용 단일 AZ
  backup_retention_period = 7     # 7일 간의 자동 백업 보관
  skip_final_snapshot     = true  # 최종 스냅샷 생략

  tags = {
    Name = "teammjk-app-db"
    Team = "infra"
  }
}