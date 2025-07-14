# 1) infra-admin 사용자 (인프라 전체 관리자)
resource "aws_iam_user" "infra_admin" {
  name = "infra-admin"
}

resource "aws_iam_user_policy_attachment" "infra_admin_attach" {
  user       = aws_iam_user.infra_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 2) dev-backend 사용자 (팀원)
resource "aws_iam_user" "dev_backend" {
  name = "dev-backend"
}

# 3) dev-backend 최소 권한 정책 문서
data "aws_iam_policy_document" "dev_backend_policy_doc" {
  statement {
    sid     = "AllowEC2Control"
    effect  = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowECRPushPull"
    effect  = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:ListImages",
      "ecr:DescribeRepositories",
      "ecr:ListRepositories",
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowSecretsManagerRead"
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      var.db_secret_arn,
      var.gemini_secret_arn,
    ]
  }
}

# 4) dev-backend용 정책 생성 및 사용자에 연결
resource "aws_iam_policy" "dev_backend_policy" {
  name   = "dev-backend-policy"
  policy = data.aws_iam_policy_document.dev_backend_policy_doc.json
}

resource "aws_iam_user_policy_attachment" "dev_backend_attach" {
  user       = aws_iam_user.dev_backend.name
  policy_arn = aws_iam_policy.dev_backend_policy.arn
}

# 5) dev-backend용 액세스 키 (SSH, CLI용)
resource "aws_iam_access_key" "dev_backend_key" {
  user = aws_iam_user.dev_backend.name
}