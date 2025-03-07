variable "app_name" {
  description = "Naam van de Amplify app"
  type        = string
  default     = "polysynergy-portal"
}

variable "repository_url" {
  description = "Repository URL van het portal"
  type        = string
  default     = "https://github.com/dionsnoeijen/polysynergy-portal"
}

variable "github_token" {
  description = "GitHub access token"
  type        = string
}

variable "branch_name" {
  description = "Branch naam van de Amplify app"
  type        = string
  default     = "main"
}

variable "domain_name" {
  description = "Domeinnaam voor het ACM certificate"
  type        = string
  default     = "portal.polysynergy.com"
}

variable "hosted_zone_id" {
  description = "De Route53 Hosted Zone ID"
  type        = string
}