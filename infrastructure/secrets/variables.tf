variable "db_secret_json" {
  description = "JSON object met database credentials"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  type = string
}

variable "subnet1_id" {
  type = string
}

variable "subnet2_id" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "cognito_app_client_id" {
  type = string
}

variable "aws_access_key_id" {
    type = string
}

variable "aws_secret_access_key" {
    type = string
}

variable "email_host_user" {
    type = string
}

variable "email_host_password" {
    type = string
}