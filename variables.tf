# 기본 인프라 설정 변수들
variable "gemini_api_key" {
  description = "Gemini(Google) API Key"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS 계정 ID"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "EC2 SSH 접근 허용 IP"
  type        = string
  sensitive   = true
}

# GitHub OIDC 설정 변수들
variable "github_owner" {
  description = "GitHub 조직/사용자 명 (owner)"
  type        = string
  default     = "TeamMJK"
}

variable "github_repo_frontend" {
  description = "프론트엔드 GitHub 레포지토리 이름"
  type        = string
  default     = "agent-web"
}

# KMS 및 Secrets Manager 설정 변수들
variable "kms_alias_name" {
  description = "KMS 키 별칭"
  type        = string
  default     = "alias/teammjk-secrets-key"
}

variable "db_password_length" {
  description = "DB 비밀번호 길이"
  type        = number
  default     = 16
}

# S3 정적 웹사이트 설정 변수들
variable "bucket_name" {
  description = "정적 웹페이지 S3 버킷 이름"
  type        = string
  default     = "teammjk-static-site-bucket"
}

variable "cloudfront_comment" {
  description = "CloudFront 배포 설명"
  type        = string
  default     = "Static Website for TeamMJK"
}

# Database 설정 변수들
variable "app_sg_ids" {
  description = "Spring Boot 및 Agent 서버 SG ID 리스트"
  type        = list(string)
  default     = []
}

# EC2 설정 변수들
variable "key_pair_name" {
  description = "EC2 인스턴스에 사용할 키 페어 이름"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
}


