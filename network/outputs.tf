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

output "vpc_endpoint_sg_id" {
  description = "The ID of the security group for VPC endpoints"
  value       = aws_security_group.vpc_endpoint.id
}

output "private_backend_route_table_id" {
  description = "Private App Subnet에 연결된 라우팅 테이블의 ID"
  value       = aws_route_table.private_backend.id
}

output "ssm_endpoint_sg_id" {
  description = "Security group ID for SSM VPC endpoints"
  value       = aws_security_group.ssm_endpoint_sg.id
}

output "ssm_vpc_endpoint_id" {
  description = "SSM VPC endpoint ID"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_messages_vpc_endpoint_id" {
  description = "SSM Messages VPC endpoint ID"
  value       = aws_vpc_endpoint.ssm_messages.id
}

output "ec2_messages_vpc_endpoint_id" {
  description = "EC2 Messages VPC endpoint ID"
  value       = aws_vpc_endpoint.ec2_messages.id
}
