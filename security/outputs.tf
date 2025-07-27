output "agent_sg_id" {
  value       = aws_security_group.agent_sg.id
  description = "Agent Security Group ID"
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "ALB Security Group ID"
}

output "backend_sg_id" {
  value       = aws_security_group.backend_sg.id
  description = "Backend Security Group ID"
}

output "db_sg_id" {
  value       = aws_security_group.db_sg.id
  description = "DB Security Group ID"
}

output "elasticache_sg_id" {
  value       = aws_security_group.elasticache_sg.id
  description = "ElastiCache Security Group ID"
}