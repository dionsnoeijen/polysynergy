output "router_alb_dns_name" {
  value = aws_lb.router_alb.dns_name
}

output "router_alb_zone_id" {
  value = aws_lb.router_alb.zone_id
}