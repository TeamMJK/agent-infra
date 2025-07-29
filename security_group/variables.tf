variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "EC2 인스턴스에 SSH 접근을 허용할 IP 주소"
  type        = string
}
