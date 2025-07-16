
# 1) 랜덤 비밀번호 생성
resource "random_password" "db_password" {
  length           = var.db_password_length
  override_special    = "!@#$%&*()-_=+[]{}<>?"
  special          = true
  upper            = true
  lower            = true
  numeric           = true
}

# 2) KMS 키 생성 (자동 키 회전)
resource "aws_kms_key" "secrets" {
  description             = "CMK for encrypting Secrets Manager secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "teammjk-secrets-key"
    Team = "infra"
  }
}

# Alias
resource "aws_kms_alias" "secrets_alias" {
  name          = var.kms_alias_name
  target_key_id = aws_kms_key.secrets.key_id
}

# 3) Secrets Manager 시크릿: Gemini API Key
resource "aws_secretsmanager_secret" "gemini" {
  name         = "/prod/geminiApiKey"
  description  = "Gemini (Google) API Key"
  kms_key_id   = aws_kms_key.secrets.arn
  recovery_window_in_days = 7
  tags = {
    Team = "infra"
  }
}

resource "aws_secretsmanager_secret_version" "gemini_version" {
  secret_id     = aws_secretsmanager_secret.gemini.id
  secret_string = var.gemini_api_key
}

# 4) Secrets Manager 시크릿: DB 자격증명
resource "aws_secretsmanager_secret" "db" {
  name         = "/prod/db"
  description  = "RDS Master user password"
  kms_key_id   = aws_kms_key.secrets.arn
  recovery_window_in_days = 7
  tags = {
    Team = "infra"
  }
}

resource "aws_secretsmanager_secret_version" "db_version" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "masteruser"
    password = random_password.db_password.result
  })
}