variable "instance_name_prefix" {
  description = "EC2 인스턴스의 Name 태그 값"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 인스턴스에 사용할 키 페어 이름"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
}

variable "subnet_ids" {
  description = "EC2 인스턴스가 배치될 서브넷 ID 목록 (Multi-AZ 지원)"
  type        = list(string)
}

variable "vpc_id" {
  description = "EC2 인스턴스가 속할 VPC ID"
  type        = string
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
}

variable "aws_account_id" {
  description = "AWS 계정 ID (ECR 로그인 시 필요)"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "EC2 인스턴스에 SSH 접근을 허용할 IP 주소"
  type        = string
}

variable "user_data_script_path" {
  description = "EC2 인스턴스에 전달할 User Data 스크립트 경로"
  type        = string
}


# ============
# for backend
# ============
variable "target_group_arns" {
  description = "인스턴스가 속할 ALB Target Group ARNs"
  type        = list(string)
  default     = []
  
}

variable "db_instance_endpoint" {
  description = "RDS DB 인스턴스 엔드포인트"
  type        = string
  default     = ""
}

variable "db_instance_port" {
  description = "RDS DB 인스턴스 포트"
  type        = number
  default     = 5432
}

variable "security_group_ids" {
  description = "EC2 인스턴스에 적용할 보안 그룹 ID 리스트"
  type        = list(string)
}

variable "elasticache_endpoint" {
  description = "ElastiCache for Redis endpoint"
  type        = string
  default     = ""
}