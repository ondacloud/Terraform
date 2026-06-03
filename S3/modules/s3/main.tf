resource "aws_s3_bucket" "this" {
  bucket   = var.name

  tags = var.tags
}
    
resource "aws_s3_object" "this" {
  for_each = var.enable_objects ? local.processed_objects : {}

  bucket       = aws_s3_bucket.this.id
  key          = each.value.key
  source       = "${path.module}/../../src/${each.value.source}"
  source_hash  = filemd5("${path.module}/../../src/${each.value.source}")
  content_type = each.value.content_type
  server_side_encryption = each.value.enable_object_kms ? var.server_side_encryption : "AES256"
  kms_key_id   = var.enable_object_kms ? var.kms_arn : null
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.enable_bucket_kms ? 1 : 0
  
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_arn != null ? var.server_side_encryption : "AES256"
      kms_master_key_id = var.kms_arn != null ? var.kms_arn : null
    }
  }
}