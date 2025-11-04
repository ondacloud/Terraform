resource "aws_kms_key" "this" {
  key_usage               = var.key_usage
  deletion_window_in_days = var.deletion_window_in_days

  tags = var.tags
}

resource "aws_kms_alias" "this" {
  target_key_id          = aws_kms_key.this.key_id
  name                   = var.alias_name
}