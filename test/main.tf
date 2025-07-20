provider "aws" {
  region = "ap-northeast-2"
}

# 1. 네트워크 기반 모듈
module "network" {
  source = "../10_network"
}

# 2. IAM 사용자 및 정책 모듈
module "iam" {
  source = "../20_iam"

  # kms_secrets 모듈의 출력을 iam 모듈 입력으로 전달
  db_secret_arn     = module.kms_secrets.db_secret_arn
  gemini_secret_arn = module.kms_secrets.gemini_secret_arn
}

# 3. 정적 웹사이트 모듈 (S3 + CloudFront)
module "static_website" {
  source = "../30_static_website"

  # 루트 변수에서 값 전달
  bucket_name        = var.bucket_name
  cloudfront_comment = var.cloudfront_comment
}

# 4. GitHub OIDC 모듈
module "github_oidc" {
  source = "../40_github_oicd"

  # 루트 변수에서 값 전달
  github_owner         = var.github_owner
  github_repo_frontend = var.github_repo_frontend
  aws_account_id       = var.aws_account_id

  # 다른 모듈의 출력값 전달
  s3_bucket                  = module.static_website.bucket_name
  cloudfront_distribution_id = module.static_website.cloudfront_distribution_id
}

# 5. KMS 및 Secrets Manager 모듈
module "kms_secrets" {
  source = "../50_kms_secrets"

  # 루트 변수에서 값 전달
  kms_alias_name     = var.kms_alias_name
  gemini_api_key     = var.gemini_api_key
  db_password_length = var.db_password_length
}

# 6. 데이터베이스 모듈
module "database" {
  source = "../60_database"

  # 루트 변수에서 값 전달
  app_sg_ids = var.app_sg_ids

  # 다른 모듈의 출력값 전달
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  kms_key_arn        = module.kms_secrets.kms_key_arn
  db_password        = module.kms_secrets.db_password
}
