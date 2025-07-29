variable "codedeploy_service_role_arn" {
  description = "CodeDeploy 서비스가 사용할 IAM 역할의 ARN"
  type        = string
}

variable "ec2_tag_key" {
  description = "배포 대상 EC2를 식별하기 위한 태그 키"
  type        = string
  default     = "backend"
}

variable "ec2_tag_value" {
  description = "배포 대상 EC2를 식별하기 위한 태그 값"
  type        = string
  default     = "SpringBoot"
}

variable "alb_listener_arn" {
  description = "Blue/Green 배포에 사용할 ALB 리스너의 ARN"
  type        = string
}

variable "blue_target_group_name" {
  description = "Blue 타겟 그룹의 이름"
  type        = string
}

variable "green_target_group_name" {
  description = "Green 타겟 그룹의 이름"
  type        = string
}
