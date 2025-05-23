output "ecs_cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "ecs_service_id" {
  value = aws_ecs_service.api_service.id
}

output "lb_dns_name" {
  value = aws_lb.api_lb.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.api_repo.repository_url
}

output "lb_zone_id" {
  value = aws_lb.api_lb.zone_id
}