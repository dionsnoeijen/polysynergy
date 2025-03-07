resource "aws_amplify_app" "portal" {
  name        = var.app_name
  repository  = var.repository_url
  access_token = var.github_token
  platform    = "WEB"
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.portal.id
  branch_name = var.branch_name
}

resource "aws_acm_certificate" "portal_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    prevent_destroy = true
  }
}