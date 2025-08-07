# AMI 데이터 소스 (변경 필요 없음)
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

# 2) Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.instance_name_prefix}-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.ec2_instance_type
  key_name      = var.key_pair_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(templatefile(var.user_data_script_path, {
    aws_account_id       = var.aws_account_id
    aws_region           = var.aws_region
    db_instance_endpoint = var.db_instance_endpoint
    db_instance_port     = var.db_instance_port
    elasticache_endpoint = var.elasticache_endpoint
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name_prefix
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 3) Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name_prefix = "${var.instance_name_prefix}-asg-"

  # 스케일링 설정
  min_size         = 1
  max_size         = 4
  desired_capacity = 1

  # Single AZ [single-az-refactor]
  vpc_zone_identifier       = var.subnet_ids # [single-az-refactor] Single AZ 서브넷만 포함
  health_check_type         = "EC2"
  health_check_grace_period = 300 # 인스턴스가 시작될 시간을 부여

  # Launch Template 사용
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  # ALB 대상 그룹에 연결
  target_group_arns = var.target_group_arns

  # 이 Auto Scaling Group이 생성한 인스턴스에 태그 지정
  tag {
    key                 = "Name"
    value               = var.instance_name_prefix
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonEC2ContainerService-managed" # 향후 ECS 연동 가능성을 위함
    value               = ""
    propagate_at_launch = true
  }
  # [single-az-refactor] Single AZ Tag
  tag {
    key                 = "AZConfiguration"
    value               = "single-az"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
