resource "aws_cloudwatch_log_group" "this" {
    name = var.name
    kms_key_id = var.enable_kms ? var.kms_key_id : null
    tags = var.tags
}