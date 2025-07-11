output "dev_backend_access_key_id" {
  value       = aws_iam_access_key.dev_backend_key.id
  description = "dev-backend IAM 사용자 Access Key ID"
}

output "dev_backend_secret_access_key" {
  value       = aws_iam_access_key.dev_backend_key.secret
  description = "dev-backend IAM 사용자 Secret Access Key"
  sensitive   = true
}