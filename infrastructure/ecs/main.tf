resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_ecr_repository" "api_repo" {
  name = var.ecr_repo_name
}

resource "aws_lb" "api_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb_security_groups
  subnets            = var.lb_subnets
}

resource "aws_lb_target_group" "api_tg" {
  name        = var.tg_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  load_balancing_algorithm_type = "round_robin"

  health_check {
    path                = "/api/health/"
    interval            = 30         # Geef meer ademruimte
    timeout             = 10         # Meer tijd per check
    unhealthy_threshold = 5
    healthy_threshold   = 2
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = false
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api_lb.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.api_lb.arn
  port              = var.https_listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.api_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}

resource "aws_acm_certificate" "api_cert" {
  domain_name       = var.api_domain_name
  validation_method = "DNS"
}

resource "aws_cloudwatch_log_group" "ecs_api_task" {
  name              = "/ecs/api-task"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "api_task" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name         = var.container_name
      image        = "${aws_ecr_repository.api_repo.repository_url}:latest"
      cpu          = tonumber(var.task_cpu),
      memory       = tonumber(var.task_memory),
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.container_port,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/api-task"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      },
      environment  = var.container_environment,
      secrets      = var.container_secrets
    }
  ])
}

resource "aws_ecs_service" "api_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_execute_command             = true

  network_configuration {
    subnets         = var.ecs_private_subnets
    security_groups = var.ecs_security_groups
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

resource "aws_route53_record" "api_cert_validation" {
  zone_id = var.hosted_zone_id
  name    = [for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.resource_record_name][0]
  type    = [for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.resource_record_type][0]
  records = [[for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.resource_record_value][0]]
  ttl     = 300
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.eu-central-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.ecs_subnets
  security_group_ids = var.ecs_security_groups
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.eu-central-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.ecs_subnets
  security_group_ids = var.ecs_security_groups
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [var.private_rt_id]
}
