variable "vpc_id" {
  description = "De VPC-ID waaraan de security group wordt gekoppeld"
  type        = string
}

variable "ecs_execution_role_name" {
  description = "Naam van de ECS Execution Role"
  type        = string
  default     = "ecs_execution_role"
}

variable "ecs_policy_attachment_name" {
  description = "Naam voor de ECS Task Execution Policy Attachment"
  type        = string
  default     = "ecs-task-execution-policy"
}

variable "ecs_task_execution_policy_arn" {
  description = "ARN van de ECS Task Execution Policy"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}