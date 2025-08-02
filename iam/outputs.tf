output "dev_backend_access_key_id" {
  value       = aws_iam_access_key.dev_backend_key.id
  description = "dev-backend IAM 사용자 Access Key ID"
}

output "dev_backend_secret_access_key" {
  value       = aws_iam_access_key.dev_backend_key.secret
  description = "dev-backend IAM 사용자 Secret Access Key"
  sensitive   = true
}

output "ec2_instance_profile_name" {
  description = "애플리케이션 EC2 인스턴스에 적용할 IAM 인스턴스 프로파일 이름"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "codedeploy_service_role_arn" {
  description = "CodeDeploy 서비스가 사용할 IAM 역할의 ARN"
  value       = aws_iam_role.codedeploy_service_role.arn
}