provider "aws" {
  region = "ap-northeast-2"
}

# 1. 네트워크 기반 모듈
module "network" {
  source = "./network"

  public_agent_subnet_cidrs = var.public_agent_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_db_subnet_cidrs   = var.private_db_subnet_cidrs
  availability_zones        = var.availability_zones
  aws_region                = var.aws_region
}

# 2. IAM 사용자 및 정책 모듈
module "iam" {
  source = "./iam"

  db_secret_arn          = module.kms_secrets.db_secret_arn
  llm_api_key_secret_arn = module.kms_secrets.llm_api_key_secret_arn
}

# 3. 정적 웹사이트 모듈 (S3 + CloudFront)
module "static_website" {
  source = "./static_website"

  bucket_name        = var.bucket_name
  cloudfront_comment = var.cloudfront_comment
}

# 4. GitHub OIDC 모듈
module "github_oidc" {
  source = "./github_oicd"

  # 공통 변수
  github_owner = var.github_owner

  # 프론트엔드용 변수
  github_repo_frontend        = var.github_repo_frontend
  s3_bucket_arn               = module.static_website.bucket_arn
  cloudfront_distribution_arn = module.static_website.cloudfront_distribution_arn

  # 백엔드용 변수
  github_repo_backend             = var.github_repo_backend
  ecr_repository_arn              = var.spring_ecr_arn # 변수로 직접 ARN 전달
  codedeploy_app_arn              = module.codedeploy.backend_arn
  codedeploy_deployment_group_arn = module.codedeploy.deployment_group_arn
}

# 5. CodeDeploy 모듈
module "codedeploy" {
  source = "./codedeploy"

  codedeploy_service_role_arn = module.iam.codedeploy_service_role_arn
  alb_listener_arn            = module.alb.http_listener_arn
  blue_target_group_name      = module.alb.blue_target_group_name
  green_target_group_name     = module.alb.green_target_group_name
}

# 5. KMS 및 Secrets Manager 모듈
module "kms_secrets" {
  source = "./kms_secrets"

  kms_alias_name     = var.kms_alias_name
  llm_api_key        = var.llm_api_key
  db_password_length = var.db_password_length
}

# 6. 데이터베이스 모듈
module "database" {
  source = "./database"

  vpc_id             = module.network.vpc_id
  db_sg_id           = module.security.db_sg_id
  private_subnet_ids = module.network.private_db_subnet_ids

  kms_key_arn = module.kms_secrets.kms_key_arn
  db_password = module.kms_secrets.db_password
}

# 6. ElastiCache for Redis 모듈
module "elasticache" {
  source = "./cache"

  cluster_id         = "teammjk-redis-cluster"
  node_type          = "cache.t3.micro"
  security_group_ids = [module.security.elasticache_sg_id]
  private_subnet_ids = module.network.private_db_subnet_ids
}


# 7. ECR 모듈
module "ecr" {
  source = "./ecr"
}

# 8. 보안 그룹 모듈
module "security" {
  source = "./security_group"

  vpc_id         = module.network.vpc_id
  ssh_allowed_ip = var.ssh_allowed_ip
}

# 9. ALB 모듈
module "alb" {
  source = "./alb"

  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [module.security.alb_sg_id]
}

# 10. 컴퓨트 모듈 (Agent) - ASG 기반
module "compute_agent" {
  source = "./compute"

  aws_region                = var.aws_region
  instance_name_prefix      = "teammjk-agent"
  key_pair_name             = var.key_pair_name
  ec2_instance_type         = var.ec2_instance_type
  aws_account_id            = var.aws_account_id
  iam_instance_profile_name = module.iam.ec2_instance_profile_name

  vpc_id         = module.network.vpc_id
  ssh_allowed_ip = var.ssh_allowed_ip

  subnet_ids = module.network.public_subnet_ids

  user_data_script_path = "./compute/user_data_agent.sh"
  security_group_ids    = [module.security.agent_sg_id]
}

# 10. 컴퓨트 모듈 (Backend) - ASG 기반
module "compute_backend" {
  source = "./compute"

  aws_region                = var.aws_region
  instance_name_prefix      = "teammjk-backend"
  key_pair_name             = var.key_pair_name
  ec2_instance_type         = var.ec2_instance_type
  aws_account_id            = var.aws_account_id
  iam_instance_profile_name = module.iam.ec2_instance_profile_name

  vpc_id         = module.network.vpc_id
  ssh_allowed_ip = var.ssh_allowed_ip

  subnet_ids = module.network.private_app_subnet_ids

  user_data_script_path = "./compute/user_data_backend.sh"
  security_group_ids    = [module.security.backend_sg_id]

  # ALB Target Groups에 연결
  target_group_arns = [
    module.alb.blue_target_group_arn,
    module.alb.green_target_group_arn
  ]

  db_instance_endpoint = module.database.db_instance_endpoint
  db_instance_port     = module.database.db_instance_port
  elasticache_endpoint = module.elasticache.elasticache_endpoint
}