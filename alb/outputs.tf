output "alb_dns_name" {
  description = "ALB의 DNS 이름"
  value       = aws_lb.main.dns_name
}

output "http_listener_arn" {
  description = "HTTP 리스너의 ARN"
  value       = aws_lb_listener.http.arn
}

output "blue_target_group_arn" {
  description = "Blue 대상 그룹의 ARN"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "Green 대상 그룹의 ARN"
  value       = aws_lb_target_group.green.arn
}

output "blue_target_group_name" {
  description = "Blue 대상 그룹의 이름"
  value       = aws_lb_target_group.blue.name
}

output "green_target_group_name" {
  description = "Green 대상 그룹의 이름"
  value       = aws_lb_target_group.green.name
}