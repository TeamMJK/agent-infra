# 1) IAM Role & Profile
resource "aws_iam_role" "instance_role" {
  name = "trip-agent-instance-role"
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
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
resource "aws_iam_instance_profile" "instance_profile" {
  name = "trip-agent-instance-profile"
  role = aws_iam_role.instance_role.name
}

# 2) Security Group
resource "aws_security_group" "app" {
  name   = "teammjk-app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.ssh_allowed_ip}/32"]  # SSH 허용 대역
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3) EC2 인스턴스
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data              = data.template_file.user_data.rendered
  tags = { Name = "teammjk-app-instance" }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
  vars = {
    aws_account_id     = var.aws_account_id
    aws_region         = data.aws_region.current.name
    db_instance_endpoint = var.db_instance_endpoint
    db_instance_port   = var.db_instance_port
  }
}

data "aws_region" "current" {}

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