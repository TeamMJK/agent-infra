variable "vpc_id" {
  description = "ALB가 생성될 VPC의 ID"
  type        = string
}

variable "subnet_ids" {
  description = "ALB를 배치할 Public Subnet ID 목록"
  type        = list(string)
}

variable "security_group_ids" {
  description = "ALB에 적용할 보안 그룹 ID 목록"
  type        = list(string)
}