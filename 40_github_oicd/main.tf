# 1) GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]  # GitHub CA

  # 허용할 subject 패턴: repo:OWNER/REPO:ref:refs/heads/브랜치
  # (여기선 main 브랜치만 허용한다고 가정)
  depends_on = []  # no dependencies
}

# 2) IAM Role for GitHub Actions
data "aws_iam_policy_document" "assume_role" {
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
      values   = [
        "repo:${var.github_owner}/${var.github_repo_frontend}:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# 3) Policy: S3 sync & CloudFront invalidation
data "aws_iam_policy_document" "actions_policy" {
  statement {
    sid    = "AllowS3Deploy"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*"
    ]
  }
  statement {
    sid    = "AllowCloudFrontInvalidate"
    effect = "Allow"
    actions = ["cloudfront:CreateInvalidation"]
    resources = ["arn:aws:cloudfront::${var.aws_account_id}:distribution/${var.cloudfront_distribution_id}"]
  }
}

resource "aws_iam_policy" "github_actions_policy" {
  name   = "github-actions-deploy-policy"
  policy = data.aws_iam_policy_document.actions_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_actions_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}