variable "cluster_name" {
  description = "Naam van de ECS-cluster"
  type        = string
  default     = "polysynergy-cluster"
}

variable "vpc_id" {
  description = "VPC-ID voor de target group"
  type        = string
}

variable "lb_subnets" {
  description = "Subnet IDs voor de load balancer"
  type        = list(string)
}

variable "lb_security_groups" {
  description = "Security groups voor de load balancer"
  type        = list(string)
}

variable "lb_name" {
  description = "Naam van de load balancer"
  type        = string
  default     = "api-load-balancer"
}

variable "tg_name" {
  description = "Naam van de target group"
  type        = string
  default     = "api-target-group"
}

variable "listener_port" {
  description = "Poort voor de HTTP listener"
  type        = number
  default     = 80
}

variable "https_listener_port" {
  description = "Poort voor de HTTPS listener"
  type        = number
  default     = 443
}

variable "api_domain_name" {
  description = "Domeinnaam voor het API certificaat"
  type        = string
  default     = "api.polysynergy.com"
}

variable "task_family" {
  description = "Task family voor de ECS task definition"
  type        = string
  default     = "api-task"
}

variable "task_cpu" {
  description = "CPU eenheden voor de taak"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory in MB voor de taak"
  type        = string
  default     = "512"
}

variable "execution_role_arn" {
  description = "IAM role ARN voor ECS task execution"
  type        = string
}

variable "container_name" {
  description = "Naam van de container"
  type        = string
  default     = "api"
}

variable "container_port" {
  description = "Container poort"
  type        = number
  default     = 8000
}

variable "container_environment" {
  description = "Environment variabelen voor de container"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
    description = "Secrets voor de container"
    type        = list(object({
        name      = string
        valueFrom = string
    }))
    default = []
}

variable "ecs_subnets" {
  description = "Subnet IDs voor de ECS service"
  type        = list(string)
}

variable "ecs_security_groups" {
  description = "Security groups voor de ECS service"
  type        = list(string)
}

variable "desired_count" {
  description = "Aantal gewenste ECS taken"
  type        = number
  default     = 1
}

variable "service_name" {
  description = "Naam van de ECS service"
  type        = string
  default     = "api-service"
}

variable "ecr_repo_name" {
  description = "Naam voor de ECR repository"
  type        = string
  default     = "polysynergy-api"
}

variable "hosted_zone_id" {
  description = "De Route53 Hosted Zone ID"
  type        = string
}

variable "aws_region" {
  description = "AWS regio waarin de resources worden aangemaakt"
  type        = string
}

variable "private_rt_id" {
  description = "ID van de private route table"
  type        = string
}

variable "ecs_private_subnets" {
  description = "Private Subnet IDs voor de ECS service"
  type        = list(string)
}

variable "ecs_task_role_arn" {
  description = "ARN van de ECS Task Role"
  type        = string
}
