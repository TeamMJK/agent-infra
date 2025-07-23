output "app_sg_id" {
  description = "Application Security Group ID"
  value       = aws_security_group.app.id
}
