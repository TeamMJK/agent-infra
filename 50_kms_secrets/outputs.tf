output "db_password" {
  value       = random_password.db_password.result
  description = "생성된 RDS Master 비밀번호 (로컬 확인용)"
  sensitive   = true
}

output "db_secret_arn" {
  value       = aws_secretsmanager_secret.db.arn
  description = "Secrets Manager /prod/db 시크릿 ARN"
}

output "gemini_secret_arn" {
  value       = aws_secretsmanager_secret.gemini.arn
  description = "Secrets Manager /prod/geminiApiKey 시크릿 ARN"
}