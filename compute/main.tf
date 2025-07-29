# 1) IAM Role & Profile
resource "aws_iam_role" "ec2_role" {
  name               = "${var.instance_name}-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume.json
}
data "aws_iam_policy_document" "instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.ec2_role.name
}

# 2) EC2 인스턴스
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  user_data = templatefile(var.user_data_script_path, {
    aws_account_id       = var.aws_account_id
    aws_region           = var.aws_region
    db_instance_endpoint = var.db_instance_endpoint
    db_instance_port     = var.db_instance_port
    elasticache_endpoint = var.elasticache_endpoint
  })

  tags = { Name = var.instance_name }
}

# AMI 데이터 소스
# Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
