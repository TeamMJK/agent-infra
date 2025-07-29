output "db_instance_endpoint" {
  value       = aws_db_instance.db.endpoint
  description = "RDS 엔드포인트 주소"
}

output "db_instance_port" {
  value       = aws_db_instance.db.port
  description = "RDS 포트 번호"
}

output "db_subnet_group_name" {
  value       = aws_db_subnet_group.db_subnet_group.name
  description = "DB 서브넷 그룹 이름"
}