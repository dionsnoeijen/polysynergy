resource "aws_route53_record" "api_dns" {
  zone_id = var.hosted_zone_id
  name    = var.api_record_name
  type    = "A"

  alias {
    name                   = var.api_alias_name
    zone_id                = var.api_alias_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "portal_dns" {
  zone_id = var.hosted_zone_id
  name    = var.portal_record_name
  type    = "CNAME"
  records = [var.portal_default_domain]
  ttl     = 300
}
