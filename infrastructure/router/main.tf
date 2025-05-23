# Router

resource "aws_ecr_repository" "router_repo" {
  name = var.ecr_router_repo_name
}

resource "aws_acm_certificate" "router_cert" {
  domain_name       = var.router_domain_name
  validation_method = "DNS"
}

# resource "aws_route53_record" "router_cert_validation" {
#   zone_id = var.router_hosted_zone_id
#   name    = [for dvo in aws_acm_certificate.router_cert.domain_validation_options : dvo.resource_record_name][0]
#   type    = [for dvo in aws_acm_certificate.router_cert.domain_validation_options : dvo.resource_record_type][0]
#   records = [[for dvo in aws_acm_certificate.router_cert.domain_validation_options : dvo.resource_record_value][0]]
#   ttl     = 300
# }

resource "aws_lb" "router_alb" {
  name               = var.router_lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb_security_groups
  subnets            = var.lb_subnets
}

resource "aws_lb_target_group" "router_tg" {
  name        = var.router_tg_name
  port        = var.router_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/__internal/health"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "router_http" {
  load_balancer_arn = aws_lb.router_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "router_https" {
  load_balancer_arn = aws_lb.router_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.router_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.router_tg.arn
  }
}

resource "aws_cloudwatch_log_group" "ecs_router_task" {
  name              = "/ecs/router-task"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "router_task" {
  family                   = var.router_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name         = var.router_container_name
      image        = "${aws_ecr_repository.router_repo.repository_url}:latest"
      command      = ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
      portMappings = [
        {
          containerPort = var.router_container_port
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_router_task.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      },
      environment = var.router_container_environment,
      secrets     = var.router_container_secrets
    }
  ])
}

resource "aws_ecs_service" "router_service" {
  name            = var.router_service_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.router_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.ecs_subnets
    security_groups = var.ecs_security_groups
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.router_tg.arn
    container_name   = var.router_container_name
    container_port   = var.router_container_port
  }
}
