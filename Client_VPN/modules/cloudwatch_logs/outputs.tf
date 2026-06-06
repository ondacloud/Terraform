output "cw_log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "cw_log_group_id" {
  value = aws_cloudwatch_log_group.this.id
}

output "cw_log_group_arn" {
  value = aws_cloudwatch_log_group.this.arn
}

output "cw_log_stream_names" {
  value = var.create_log_stream ? { for k, v in aws_cloudwatch_log_stream.this : k => v.name } : {}
}