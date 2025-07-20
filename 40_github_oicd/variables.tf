variable "github_owner" {
  description = "GitHub 조직/사용자 명 (owner)"
  type        = string
}

variable "github_repo_frontend" {
  description = "GitHub 레포지토리 이름"
  type        = string
}

variable "aws_account_id" {
  description = "AWS 계정 ID"
  type        = string
}

variable "s3_bucket" {
  description = "배포 대상 S3 버킷 이름"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  type        = string
}