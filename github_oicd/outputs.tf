output "github_oidc_provider_arn" {
  description = "GitHub OIDC Provider의 ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_frontend_role_arn" {
  description = "프론트엔드 GitHub Actions를 위한 IAM Role의 ARN"
  value       = aws_iam_role.github_actions_frontend.arn
}

output "github_actions_backend_role_arn" {
  description = "백엔드 GitHub Actions를 위한 IAM Role의 ARN"
  value       = aws_iam_role.github_actions_backend.arn
}