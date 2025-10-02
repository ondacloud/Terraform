output "rds_user_name" {
  value = aws_rds_cluster.this.master_username
}

output "rds_user_password" {
  value = aws_rds_cluster.this.master_password
  sensitive = true
}

output "rds_address" {
  value = aws_rds_cluster.this.endpoint
}

output "rds_port" {
  value = aws_rds_cluster.this.port
}

output "rds_db_name" {
  value = aws_rds_cluster.this.database_name
}