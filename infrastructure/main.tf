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
}

module "database" {
  source                  = "./database"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_username             = var.db_username
  db_password             = var.db_password
  db_name                 = "polysynergy_db"
  vpc_security_group_ids  = [module.iam_security.ecs_sg_id]
}

module "ecs" {
  source                = "./ecs"
  cluster_name          = "polysynergy-cluster"
  vpc_id                = module.network.vpc_id
  lb_subnets            = [module.network.subnet1_id, module.network.subnet2_id]
  lb_security_groups    = [module.iam_security.ecs_sg_id]
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
      name  = "DATABASE_URL"
      value = "postgres://${var.db_username}:${var.db_password}@${module.database.rds_endpoint}/polysynergy_db"
    }
  ]
  ecs_subnets         = [module.network.subnet1_id, module.network.subnet2_id]
  ecs_security_groups = [module.iam_security.ecs_sg_id]
  desired_count       = 1
  service_name        = "api-service"
  ecr_repo_name       = "polysynergy-api"
}

module "amplify" {
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