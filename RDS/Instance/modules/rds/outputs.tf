output "rds_user_name" {
  value = aws_db_instance.this.username
}

output "rds_user_password" {
  value     = aws_db_instance.this.password
  sensitive = true
}

output "rds_address" {
  value = aws_db_instance.this.address
}

output "rds_port" {
  value = aws_db_instance.this.port
}

output "rds_db_name" {
  value = var.db_name
}