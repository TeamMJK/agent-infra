# ====================================================================================
# IAM Users and Roles for Team Members
# ====================================================================================

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
      var.llm_api_key_secret_arn,
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


# ====================================================================================
# EC2 IAM Role for Application
# ====================================================================================
resource "aws_iam_role" "ec2_app_role" {
  name = "teammjk-ec2-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "teammjk-ec2-app-role"
  }
}

# --- Policy for Secrets Manager ---
data "aws_iam_policy_document" "ec2_secrets_policy_doc" {
  statement {
    sid       = "AllowSecretsManagerRead"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.db_secret_arn, var.llm_api_key_secret_arn]
  }
}

resource "aws_iam_policy" "ec2_secrets_policy" {
  name   = "teammjk-ec2-secrets-policy"
  policy = data.aws_iam_policy_document.ec2_secrets_policy_doc.json
}

# --- Attach policies to EC2 Role ---
resource "aws_iam_role_policy_attachment" "ec2_secrets_attach" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.ec2_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_attach" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_attach" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --- Instance Profile ---
resource "aws_iam_instance_profile" "ec2_app_instance_profile" {
  name = "teammjk-ec2-app-instance-profile"
  role = aws_iam_role.ec2_app_role.name
}


# ====================================================================================
# CodeDeploy Service IAM Role
# ====================================================================================
resource "aws_iam_role" "codedeploy_service_role" {
  name = "teammjk-codedeploy-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "teammjk-codedeploy-service-role"
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_service_attach" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}
