# 1. ALB
resource "aws_lb" "main" {
  name               = "teammjk-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "teammjk-alb"
    # Single AZ 설정 [single-az-refactor]
    AZConfiguration = "single-az"
    Environment = "cost-optimized" # 비용 최적화 구성임을 명시
  }
}

# 2. Target Groups (Blue/Green)
resource "aws_lb_target_group" "blue" {
  name     = "teammjk-blue-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "teammjk-blue-tg"
  }
}

resource "aws_lb_target_group" "green" {
  name     = "teammjk-green-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "teammjk-green-tg"
  }
}

# 3. Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}
