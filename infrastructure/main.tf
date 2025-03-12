module "network" {
  source        = "./network"
  vpc_cidr      = "10.0.0.0/16"
  vpc_name      = "main-vpc"
  subnet1_cidr  = "10.0.1.0/24"
  subnet2_cidr  = "10.0.2.0/24"
  az1           = "eu-central-1a"
  az2           = "eu-central-1b"
}

module "iam_security" {
  source                         = "./iam-security"
  vpc_id                         = module.network.vpc_id
  ecs_execution_role_name        = "ecs_execution_role"
  ecs_policy_attachment_name     = "ecs-task-execution-policy"
  ecs_task_execution_policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  lb_security_group_id           = module.iam_security.lb_security_group_id
}

module "database" {
  source                  = "./database"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_username             = var.db_username
  db_password             = var.db_password
  db_name                 = "polysynergy_db"
  vpc_security_group_ids  = [module.iam_security.ecs_sg_id]
  subnet1_id              = module.network.subnet1_id
  subnet2_id              = module.network.subnet2_id
  ecs_sg_id               = module.iam_security.ecs_sg_id
  ssh_key_name            = "bastion-key"
  vpc_id                  = module.network.vpc_id
}

module "secrets" {
  source = "./secrets"
  db_secret_json = jsonencode({
    DATABASE_PASSWORD = var.db_password
  })
  cognito_app_client_id = var.cognito_app_client_id
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  email_host_user = var.email_host_user
  email_host_password = var.email_host_password
  vpc_id = module.network.vpc_id
  secret_key = var.secret_key
  subnet1_id = module.network.subnet1_id
  subnet2_id = module.network.subnet2_id
  ecs_sg_id = module.iam_security.ecs_sg_id
}

module "ecs" {
  source                = "./ecs"
  hosted_zone_id        = "/hostedzone/Z00983943HO41LU8F7S0Q"
  cluster_name          = "polysynergy-cluster"
  vpc_id                = module.network.vpc_id
  lb_subnets            = [module.network.subnet1_id, module.network.subnet2_id]
  lb_security_groups    = [module.iam_security.lb_security_group_id]
  lb_name               = "api-load-balancer"
  tg_name               = "api-target-group"
  listener_port         = 80
  https_listener_port   = 443
  api_domain_name       = "api.polysynergy.com"
  task_family           = "api-task"
  task_cpu              = "256"
  task_memory           = "512"
  execution_role_arn    = module.iam_security.ecs_execution_role_arn
  container_name        = "api"
  container_port        = 8000
  container_environment = [
    {
      name  = "DATABASE_NAME",
      value = "polysynergy_db"
    },
    {
      name  = "DATABASE_USER",
      value = var.db_username
    },
    {
      name  = "DATABASE_HOST",
      value = module.database.rds_endpoint
    },
    {
      name  = "DATABASE_PORT",
      value = "5432"
    },
    {
      name  = "DJANGO_ENV"
      value = "production"
    },
    { name = "COGNITO_AWS_REGION", value = "eu-central-1" },
    { name = "COGNITO_USER_POOL_ID", value = "eu-central-1_4YIwY5azU" },
    { name = "AWS_REGION", value = "eu-central-1" },
    { name = "AWS_ACM_CERT_ARN", value = "arn:aws:acm:eu-central-1:754508895309:certificate/cc97f106-2a3a-45c9-bfcf-66398a4b3052" },
    { name = "AWS_LAMBDA_EXECUTION_ROLE", value = "arn:aws:iam::754508895309:role/PolySynergyLambdaExecution" },
    { name = "AWS_LAMBDA_LAYER_ARN", value = "arn:aws:lambda:eu-central-1:754508895309:layer:poly_nodes_layer:9" },
    { name = "PORTAL_URL", value = "https://portal.polysynergy.com" }
  ]
  container_secrets = [
    {
      name      = "DATABASE_PASSWORD",
      valueFrom = "${module.secrets.db_secret_arn}:DATABASE_PASSWORD::"
    },
    {
      name      = "COGNITO_APP_CLIENT_ID",
      valueFrom = "${module.secrets.app_secrets_arn}:COGNITO_APP_CLIENT_ID::"
    },
    {
      name      = "AWS_ACCESS_KEY_ID",
      valueFrom = "${module.secrets.app_secrets_arn}:AWS_ACCESS_KEY_ID::"
    },
    {
      name      = "AWS_SECRET_ACCESS_KEY",
      valueFrom = "${module.secrets.app_secrets_arn}:AWS_SECRET_ACCESS_KEY::"
    },
    {
      name      = "EMAIL_HOST_USER",
      valueFrom = "${module.secrets.app_secrets_arn}:EMAIL_HOST_USER::"
    },
    {
      name      = "EMAIL_HOST_PASSWORD",
      valueFrom = "${module.secrets.app_secrets_arn}:EMAIL_HOST_PASSWORD::"
    },
    {
      name      = "SECRET_KEY",
      valueFrom = "${module.secrets.app_secrets_arn}:SECRET_KEY::"
    }
  ]
  ecs_subnets         = [module.network.subnet1_id, module.network.subnet2_id]
  ecs_security_groups = [module.iam_security.ecs_sg_id]
  desired_count       = 2
  service_name        = "api-service"
  ecr_repo_name       = "polysynergy-api"
  aws_region          = "eu-central-1"
  private_rt_id       = module.network.private_rt_id
  ecs_private_subnets = [module.network.private_subnet1_id, module.network.private_subnet2_id]
  ecs_task_role_arn   = module.iam_security.ecs_task_role_arn
}

module "amplify" {
  hosted_zone_id = "/hostedzone/Z00983943HO41LU8F7S0Q"
  source         = "./amplify"
  app_name       = "polysynergy-portal"
  repository_url = "https://github.com/dionsnoeijen/polysynergy-portal"
  github_token   = var.github_token
  branch_name    = "main"
  domain_name    = "portal.polysynergy.com"
}

module "dns" {
  source                = "./dns"
  hosted_zone_id        = "/hostedzone/Z00983943HO41LU8F7S0Q"
  api_record_name       = "api.polysynergy.com"
  api_alias_name        = module.ecs.lb_dns_name
  api_alias_zone_id     = module.ecs.lb_zone_id
  portal_record_name    = "portal.polysynergy.com"
  portal_default_domain = module.amplify.default_domain
}