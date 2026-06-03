resource "aws_sqs_queue" "this" {
  name                              = var.fifo_queue ? "${var.name}.fifo" : var.name
  delay_seconds                     = var.delay_seconds
  max_message_size                  = var.max_message_size
  message_retention_seconds         = var.message_retention_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.fifo_queue ? var.content_based_deduplication : null
  fifo_throughput_limit             = var.fifo_queue ? var.fifo_throughput_limit : null
  deduplication_scope               = var.fifo_queue ? var.deduplication_scope : null
  kms_master_key_id                 = var.enable_kms ? var.kms_key_id : null
  kms_data_key_reuse_period_seconds = var.enable_kms ? var.kms_data_key_reuse_period_seconds : null
  sqs_managed_sse_enabled           = var.enable_kms ? null : var.sqs_managed_sse_enabled

  tags = var.tags
}