variable "vpc_id" {
  description = "ID van de VPC"
  type        = string
}

variable "ecs_subnets" {
  description = "Subnetten waarin ECS tasks draaien"
  type        = list(string)
}

variable "lb_subnets" {
  description = "Subnetten voor de load balancer"
  type        = list(string)
}

variable "lb_security_groups" {
  description = "Security groups voor de load balancer"
  type        = list(string)
}

variable "ecs_security_groups" {
  description = "Security groups voor de ECS service"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "IAM execution role voor ECS taak"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "IAM task role voor ECS taak"
  type        = string
}

variable "aws_region" {
  description = "AWS regio"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ID van het ECS cluster"
  type        = string
}

variable "router_hosted_zone_id" {
  description = "Route53 Hosted Zone ID voor de router"
  type        = string
}

variable "ecr_router_repo_name" {
  description = "Naam voor de ECR router repository"
  type        = string
  default     = "polysynergy-router"
}

variable "router_lb_name" {
  description = "Naam van de router load balancer"
  type        = string
  default     = "router-load-balancer"
}

variable "router_tg_name" {
  description = "Naam van de router target group"
  type        = string
  default     = "router-target-group"
}

variable "router_task_family" {
  description = "Task family voor de router ECS task"
  type        = string
  default     = "router-task"
}

variable "router_container_name" {
  description = "Naam van de router container"
  type        = string
  default     = "router"
}

variable "router_container_port" {
  description = "Poort waarop de router container luistert"
  type        = number
  default     = 8080
}

variable "router_service_name" {
  description = "Naam van de router ECS service"
  type        = string
  default     = "router-service"
}

variable "router_domain_name" {
  description = "Wildcard domeinnaam voor router certificaat"
  type        = string
  default     = "*.polysynergy.com"
}

variable "router_container_environment" {
  description = "Environment variabelen voor de router container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "router_container_secrets" {
  description = "Secrets voor de router container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}