# =====================================================================================
# Frontend (S3/CloudFront) IAM Role for GitHub Actions
# =====================================================================================

# 1) IAM Role for Frontend GitHub Actions
data "aws_iam_policy_document" "frontend_assume_role" {
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
      values   = ["repo:${var.github_owner}/${var.github_repo_frontend}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_actions_frontend" {
  name               = "github-actions-frontend-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.frontend_assume_role.json
}

# 2) Policy for Frontend GitHub Actions (S3 Sync, CloudFront Invalidation)
data "aws_iam_policy_document" "frontend_actions_policy" {
  statement {
    sid    = "AllowS3Deploy"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }
  statement {
    sid    = "AllowCloudFrontInvalidate"
    effect = "Allow"
    actions = ["cloudfront:CreateInvalidation"]
    resources = [var.cloudfront_distribution_arn]
  }
}

resource "aws_iam_policy" "github_actions_frontend_policy" {
  name   = "github-actions-frontend-deploy-policy"
  policy = data.aws_iam_policy_document.frontend_actions_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_frontend_actions_policy" {
  role       = aws_iam_role.github_actions_frontend.name
  policy_arn = aws_iam_policy.github_actions_frontend_policy.arn
}