variable "key_pair_name" {
  description = "EC2 인스턴스에 사용할 키 페어 이름"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
}



variable "public_subnets" {
  description = "EC2 인스턴스를 배치할 퍼블릭 서브넷 ID 리스트"
  type        = list(string)
}

variable "vpc_id" {
  description = "EC2 인스턴스가 속할 VPC ID"
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

variable "db_instance_endpoint" {
  description = "RDS DB 인스턴스 엔드포인트"
  type        = string
}

variable "db_instance_port" {
  description = "RDS DB 인스턴스 포트"
  type        = number
}
