resource "aws_secretsmanager_secret" "db_secret" {
  name = "polysynergy-db-secret"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = var.db_secret_json
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.eu-central-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [var.subnet1_id, var.subnet2_id]
  security_group_ids = [var.ecs_sg_id]
  private_dns_enabled = true
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name = "polysynergy-app-secrets"
}

resource "aws_secretsmanager_secret_version" "app_secrets_version" {
  secret_id     = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    COGNITO_APP_CLIENT_ID   = var.cognito_app_client_id
    AWS_ACCESS_KEY_ID       = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY   = var.aws_secret_access_key
    EMAIL_HOST_USER         = var.email_host_user
    EMAIL_HOST_PASSWORD     = var.email_host_password
  })
}
