variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type    = string
  default = "polysynergy_db"
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet1_id" {
  type = string
}

variable "subnet2_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "ssh_key_name" {
  type = string
}