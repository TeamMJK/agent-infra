# 네트워크 관련
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "private_subnets" {
  description = "Private 서브넷 ID 리스트"
  value       = module.network.public_subnet_ids
}

output "public_subnets" {
  description = "Public 서브넷 ID 리스트"
  value       = module.network.public_subnet_ids
}

# KMS 및 Secrets Manager 관련
output "kms_key_id" {
  description = "KMS 키 ID"
  value       = module.kms_secrets.kms_key_id
}

output "kms_key_arn" {
  description = "KMS 키 ARN"
  value       = module.kms_secrets.kms_key_arn
}

output "db_secret_arn" {
  description = "데이터베이스 비밀 ARN"
  value       = module.kms_secrets.db_secret_arn
}

output "gemini_secret_arn" {
  description = "Gemini API Key 비밀 ARN"
  value       = module.kms_secrets.gemini_secret_arn
}

# IAM 관련
output "dev_backend_access_key_id" {
  description = "Dev Backend 사용자 Access Key ID"
  value       = module.iam.dev_backend_access_key_id
}

output "dev_backend_secret_access_key" {
  description = "Dev Backend 사용자 Secret Access Key"
  value       = module.iam.dev_backend_secret_access_key
  sensitive   = true
}

# 정적 웹사이트 관련
output "bucket_name" {
  description = "S3 버킷 이름"
  value       = module.static_website.bucket_name
}

output "bucket_arn" {
  description = "S3 버킷 ARN"
  value       = module.static_website.bucket_arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  value       = module.static_website.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront 도메인 이름"
  value       = module.static_website.cloudfront_domain_name
}

# GitHub OIDC 관련
output "github_oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = module.github_oidc.github_oidc_provider_arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = module.github_oidc.github_actions_role_arn
}

# 데이터베이스 관련
output "database_endpoint" {
  description = "RDS 인스턴스 엔드포인트"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "db_instance_port" {
  description = "RDS 인스턴스 포트"
  value       = module.database.db_instance_port
}

output "db_subnet_group_name" {
  description = "DB 서브넷 그룹 이름"
  value       = module.database.db_subnet_group_name
}
