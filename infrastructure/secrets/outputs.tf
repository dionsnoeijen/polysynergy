output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}

output "app_secrets_arn" {
  value = aws_secretsmanager_secret.app_secrets.arn
}