output "app_name" {
  description = "CodeDeploy 애플리케이션의 이름"
  value       = aws_codedeploy_app.backend.name
}

output "backend_arn" {
  description = "CodeDeploy 애플리케이션의 ARN"
  value       = aws_codedeploy_app.backend.arn
}

output "deployment_group_arn" {
  description = "CodeDeploy 배포 그룹의 ARN"
  value       = aws_codedeploy_deployment_group.backend.arn
}