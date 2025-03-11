output "rds_endpoint" {
  value = replace(aws_db_instance.postgres.endpoint, ":5432", "")
}
