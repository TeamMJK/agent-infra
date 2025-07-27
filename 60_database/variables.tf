# infra/60_database/variables.tf

variable "app_sg_ids" {
  description = "Spring Boot 및 Agent 서버 SG ID 리스트"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private 서브넷 ID 리스트"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS 키 ARN"
  type        = string
}

variable "db_password" {
  description = "데이터베이스 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_sg_id" {
  description = "DB Security Group ID"
  type        = string
}
