module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "teammjk-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-northeast-2a", "ap-northeast-2c"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]   # ALB, EC2
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"] # RDS

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  map_public_ip_on_launch = true
}
