resource "aws_amplify_app" "portal" {
  name         = var.app_name
  repository   = var.repository_url
  access_token = var.github_token
  platform     = "WEB"

  environment_variables = {
    NEXT_PUBLIC_AWS_COGNITO_AUTHORITY     = "https://cognito-idp.eu-central-1.amazonaws.com/eu-central-1_4YIwY5azU"
    NEXT_PUBLIC_AWS_COGNITO_DOMAIN        = "https://auth.polysynergy.com"
    NEXT_PUBLIC_AWS_COGNITO_CLIENT_ID     = "2tbsdgjk6tfd8fqchmlcn47ir2"
    NEXT_PUBLIC_AWS_COGNITO_LOGOUT_URL    = "https://portal.polysynergy.com/sign-out"
    NEXT_PUBLIC_AWS_COGNITO_REDIRECT_URL  = "https://portal.polysynergy.com"
  }
}

resource "aws_amplify_domain_association" "portal" {
  app_id      = aws_amplify_app.portal.id
  domain_name = var.domain_name

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "" # Leeg laten betekent dat het de root is (portal.polysynergy.com)
  }
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

resource "aws_route53_record" "portal_cert_validation" {
  zone_id = var.hosted_zone_id
  name    = [for dvo in aws_acm_certificate.portal_cert.domain_validation_options : dvo.resource_record_name][0]
  type    = [for dvo in aws_acm_certificate.portal_cert.domain_validation_options : dvo.resource_record_type][0]
  records = [[for dvo in aws_acm_certificate.portal_cert.domain_validation_options : dvo.resource_record_value][0]]
  ttl     = 300
}
