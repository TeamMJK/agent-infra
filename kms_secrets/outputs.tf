output "db_password" {
  value       = random_password.db_password.result
  description = "생성된 RDS Master 비밀번호 (로컬 확인용)"
  sensitive   = true
}

output "db_secret_arn" {
  value       = aws_secretsmanager_secret.db.arn
  description = "Secrets Manager /teammjk/db 시크릿 ARN"
}

output "llm_api_key_secret_arn" {
  value       = aws_secretsmanager_secret.llm_api_key.arn
  description = "Secrets Manager /teammjk/llm_api_key 시크릿 ARN"
}

output "kms_key_arn" {
  value       = aws_kms_key.secrets.arn
  description = "KMS 키 ARN"
}

output "kms_key_id" {
  value       = aws_kms_key.secrets.key_id
  description = "KMS 키 ID"
}