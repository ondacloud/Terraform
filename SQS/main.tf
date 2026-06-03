module "kms" {
  source = "./modules/kms"

  for_each = local.kmss

  name                    = each.key
  tags                    = each.value.tags
  alias_name              = each.value.alias_name
  key_usage               = each.value.key_usage
  deletion_window_in_days = each.value.deletion_window_in_days
  statements              = each.value.statements
}

module "sqs" {
  source = "./modules/sqs"

  for_each = local.sqss

  name = each.key
  tags = each.value.tags

  delay_seconds = each.value.delay_seconds
  max_message_size = each.value.max_message_size
  message_retention_seconds = each.value.message_retention_seconds
  receive_wait_time_seconds = each.value.receive_wait_time_seconds
  visibility_timeout_seconds = each.value.visibility_timeout_seconds

  fifo_queue = each.value.fifo_queue 
  content_based_deduplication = each.value.content_based_deduplication
  fifo_throughput_limit = each.value.fifo_throughput_limit
  deduplication_scope = each.value.deduplication_scope

  enable_kms = each.value.enable_kms
  kms_data_key_reuse_period_seconds = each.value.kms_data_key_reuse_period_seconds
  kms_key_id = module.kms[each.value.kms_name].kms_key_id
  # kms_key_id = null
  sqs_managed_sse_enabled = each.value.sqs_managed_sse_enabled
  
}