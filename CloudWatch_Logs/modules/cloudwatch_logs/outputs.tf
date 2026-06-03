output "cloudwatch_logs_id" {
  value = aws_cloudwatch_log_group.this.id
}

output "cloudwatch_logs_arn" {
  value = aws_cloudwatch_log_group.this.arn
}