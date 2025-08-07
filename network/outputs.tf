output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_agent_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = [for s in aws_subnet.public_agent : s.id]
}

output "private_backend_subnet_ids" {
  description = "List of IDs of private application subnets"
  value       = [for s in aws_subnet.private_backend : s.id]
}

output "private_db_subnet_ids" {
  description = "List of IDs of private database subnets"
  value       = [for s in aws_subnet.private_db : s.id]
}

output "private_backend_route_table_id" {
  description = "Private App Subnet에 연결된 라우팅 테이블의 ID"
  value       = aws_route_table.private_backend.id
}
