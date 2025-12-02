output "secrets_manager_arn" {
  value = aws_secretsmanager_secret.this.arn
}