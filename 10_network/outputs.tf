output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_app_subnet_ids" {
  description = "List of IDs of private application subnets"
  value       = [for s in aws_subnet.private_app : s.id]
}

output "private_db_subnet_ids" {
  description = "List of IDs of private database subnets"
  value       = [for s in aws_subnet.private_db : s.id]
}