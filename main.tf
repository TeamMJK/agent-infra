provider "aws" {
  region = "ap-northeast-2"
}

# 1. 네트워크 기반 모듈
module "network" {
  source = "./10_network"

  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  availability_zones       = var.availability_zones
}

# 2. IAM 사용자 및 정책 모듈
module "iam" {
  source = "./20_iam"

  db_secret_arn     = module.kms_secrets.db_secret_arn
  gemini_secret_arn = module.kms_secrets.gemini_secret_arn
}

# 3. 정적 웹사이트 모듈 (S3 + CloudFront)
module "static_website" {
  source = "./30_static_website"

  bucket_name        = var.bucket_name
  cloudfront_comment = var.cloudfront_comment
}

# 4. GitHub OIDC 모듈
module "github_oidc" {
  source = "./40_github_oicd"

  github_owner         = var.github_owner
  github_repo_frontend = var.github_repo_frontend
  aws_account_id       = var.aws_account_id

  s3_bucket                  = module.static_website.bucket_name
  cloudfront_distribution_id = module.static_website.cloudfront_distribution_id
}

# 5. KMS 및 Secrets Manager 모듈
module "kms_secrets" {
  source = "./50_kms_secrets"

  kms_alias_name     = var.kms_alias_name
  gemini_api_key     = var.gemini_api_key
  db_password_length = var.db_password_length
}

# 6. 데이터베이스 모듈
resource "aws_db_subnet_group" "main" {
  name       = "teammjk-db-subnet-group"
  subnet_ids = module.network.private_db_subnet_ids

  tags = {
    Name = "TeamMJK DB Subnet Group"
  }
}

module "database" {
  source = "./60_database"

  vpc_id             = module.network.vpc_id
  db_sg_id           = module.security.db_sg_id
  private_subnet_ids = module.network.private_db_subnet_ids

  kms_key_arn = module.kms_secrets.kms_key_arn
  db_password = module.kms_secrets.db_password
}

# 7. ECR 모듈
module "ecr" {
  source = "./70_ecr"
}

# 8. 보안 그룹 모듈
module "security" {
  source = "./security"

  vpc_id         = module.network.vpc_id
  ssh_allowed_ip = var.ssh_allowed_ip
}

# 9. 컴퓨트 모듈 (Agent)
module "compute_agent" {
  source   = "./80_compute"
  for_each = { for i, subnet_id in module.network.public_subnet_ids : i => subnet_id }

  aws_region            = var.aws_region
  instance_name         = "teammjk-agent-instance-${each.key + 1}"
  key_pair_name         = var.key_pair_name
  ec2_instance_type     = var.ec2_instance_type
  aws_account_id        = var.aws_account_id
  ssh_allowed_ip        = var.ssh_allowed_ip

  vpc_id                = module.network.vpc_id
  subnet_id             = each.value

  user_data_script_path = "./80_compute/user_data_agent.sh"
  security_group_ids    = [module.security.agent_sg_id]
}

# 9. 컴퓨트 모듈 (Backend)
module "compute_backend" {
  source   = "./80_compute"
  for_each = { for i, subnet_id in module.network.private_app_subnet_ids : i => subnet_id }

  aws_region            = var.aws_region
  instance_name         = "teammjk-backend-instance-${each.key + 1}"
  key_pair_name         = var.key_pair_name
  ec2_instance_type     = var.ec2_instance_type
  aws_account_id        = var.aws_account_id
  ssh_allowed_ip        = var.ssh_allowed_ip

  vpc_id                = module.network.vpc_id
  subnet_id             = each.value

  user_data_script_path = "./80_compute/user_data_backend.sh"
  security_group_ids    = [module.security.backend_sg_id]

  db_instance_endpoint  = module.database.db_instance_endpoint
  db_instance_port      = module.database.db_instance_port
  elasticache_endpoint  = module.elasticache.elasticache_endpoint
}

# 10. ElastiCache 모듈
resource "aws_elasticache_subnet_group" "main" {
  name       = "teammjk-elasticache-subnet-group"
  subnet_ids = module.network.private_db_subnet_ids
}

module "elasticache" {
  source = "./90_elasticache"

  cluster_id         = "teammjk-redis-cluster"
  node_type          = "cache.t3.micro"
  security_group_ids = [module.security.elasticache_sg_id]
  private_subnet_ids = module.network.private_db_subnet_ids
}
