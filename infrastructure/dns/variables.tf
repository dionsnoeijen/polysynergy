variable "hosted_zone_id" {
  description = "De Route53 Hosted Zone ID"
  type        = string
}

variable "api_record_name" {
  description = "DNS record voor de API"
  type        = string
  default     = "api.polysynergy.com"
}

variable "api_alias_name" {
  description = "Alias naam van de API load balancer"
  type        = string
}

variable "api_alias_zone_id" {
  description = "Alias zone ID van de API load balancer"
  type        = string
}

variable "portal_record_name" {
  description = "DNS record voor het portal"
  type        = string
  default     = "portal.polysynergy.com"
}

variable "portal_default_domain" {
  description = "De default domain die Amplify voor het portal levert"
  type        = string
}

variable "router_record_name" {
  description = "Wildcard DNS record voor de router"
  type        = string
  default     = "*.polysynergy.com"
}

variable "router_alias_name" {
  description = "Alias naam van de router load balancer (ALB DNS)"
  type        = string
}

variable "router_alias_zone_id" {
  description = "Alias zone ID van de router load balancer"
  type        = string
}