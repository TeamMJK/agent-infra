# ====================================================================================
# Backend (ECR/CodeDeploy) IAM Role for GitHub Actions
# ====================================================================================

# 1) IAM Role for Backend GitHub Actions
data "aws_iam_policy_document" "backend_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo_backend}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_actions_backend" {
  name               = "github-actions-backend-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.backend_assume_role.json
}

# 2) Policy for Backend GitHub Actions (ECR Push, CodeDeploy)
data "aws_iam_policy_document" "backend_actions_policy" {
  # ECR Push 권한
  statement {
    sid    = "AllowECRPush"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = [var.ecr_repository_arn]
  }

  # CodeDeploy 배포 실행 권한
  statement {
    sid    = "AllowCodeDeploy"
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetDeploymentGroup"
    ]
    resources = [
      var.codedeploy_app_arn,
      var.codedeploy_deployment_group_arn
    ]
  }
}

resource "aws_iam_policy" "github_actions_backend_policy" {
  name   = "github-actions-backend-deploy-policy"
  policy = data.aws_iam_policy_document.backend_actions_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_backend_actions_policy" {
  role       = aws_iam_role.github_actions_backend.name
  policy_arn = aws_iam_policy.github_actions_backend_policy.arn
}