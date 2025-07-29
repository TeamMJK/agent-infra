variable "github_owner" {
  description = "리포지토리를 소유한 GitHub 조직 또는 사용자 이름"
  type        = string
}

variable "github_repo_frontend" {
  description = "프론트엔드 GitHub 리포지토리 이름"
  type        = string
}

variable "github_repo_backend" {
  description = "백엔드 GitHub 리포지토리 이름"
  type        = string
}



# Frontend Variables
variable "s3_bucket_arn" {
  description = "프론트엔드 배포용 S3 버킷의 ARN"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "프론트엔드 배포용 CloudFront Distribution의 ARN"
  type        = string
}

# Backend Variables
variable "ecr_repository_arn" {
  description = "백엔드 배포용 ECR 리포지토리의 ARN"
  type        = string
}

variable "codedeploy_app_arn" {
  description = "CodeDeploy 애플리케이션의 ARN"
  type        = string
}

variable "codedeploy_deployment_group_arn" {
  description = "CodeDeploy 배포 그룹의 ARN"
  type        = string
}