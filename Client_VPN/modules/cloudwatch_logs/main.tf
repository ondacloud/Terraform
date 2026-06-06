resource "aws_cloudwatch_log_group" "this" {
  name = var.name
  kms_key_id = try(var.kms_key_id, null)
    
  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "this" {
  for_each = var.create_log_stream ? { for name in var.log_stream_names : name => name } : {}

  name = each.key
  log_group_name = aws_cloudwatch_log_group.this.name
}