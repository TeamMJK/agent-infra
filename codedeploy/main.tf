resource "aws_codedeploy_app" "backend" {
  compute_platform = "Server"
  name             = "teammjk-backend-app"

  tags = {
    Name = "teammjk-backend-app"
  }
}

resource "aws_codedeploy_deployment_group" "backend" {
  app_name              = aws_codedeploy_app.backend.name
  deployment_group_name = "teammjk-backend-deployment-group"
  service_role_arn      = var.codedeploy_service_role_arn

  ec2_tag_filter {
    key   = var.ec2_tag_key
    type  = "KEY_AND_VALUE"
    value = var.ec2_tag_value
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      # Blue 인스턴스 종료 전 Green 인스턴스 안정성 확인 시간 확보
      termination_wait_time_in_minutes = 10
    }
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_arn]
      }

      target_group {
        name = var.blue_target_group_name
      }

      target_group {
        name = var.green_target_group_name
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    # Single AZ 환경에서 더 민감한 롤백 조건 설정
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  # Single AZ 환경 식별을 위한 태그 추가
  tags = {
    Name = "teammjk-backend-deployment-group"
    Environment = "single-az"
    DeploymentStrategy = "blue-green-single-az"
  }
}