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

module "dynamodb" {
  depends_on = [ module.kms ]
  source = "./modules/dynamodb"

  for_each = local.dynamodbs

  name           = each.key
  tags           = each.value.tags
  billing_mode   = each.value.billing_mode
  read_capacity  = each.value.read_capacity
  write_capacity = each.value.write_capacity
  hash_key       = each.value.hash_key
  range_key      = each.value.range_key
  attributes     = each.value.attributes
  server_side_encryption = each.value.enable_kms ? {
    enabled = each.value.enable_kms
    kms_key_arn = module.kms[each.value.kms_key_name].kms_arn
    # kms_key_arn = null
  } : null
  ttl = each.value.enable_ttl ? {
    enabled = each.value.enable_ttl
    attribute_name = each.value.ttl_attribute_name
  } : null
  point_in_time_recovery = each.value.enable_point_in_time_recovery ? {
    enabled = each.value.point_in_time_recovery
  } : null
  local_secondary_indexes = each.value.enable_local_secondary_indexes ? each.value.local_secondary_indexes : null
  global_secondary_indexes = each.value.enable_global_secondary_indexes ? each.value.global_secondary_indexes : null
  replicas = each.value.enable_replicas ? [
    for r in each.value.replicas : {
      region_name = r.region_name
      propagate_tags = r.propagate_tags
      point_in_time_recovery = r.enable_replica_point_in_time_recovery ? r.point_in_time_recovery : null
      consistency_mode = r.consistency_mode
      kms_key_arn = r.enable_replica_kms ? module.kms[r.kms_key_name].kms_arn : null
      # kms_key_arn = null
    }
  ] : null
  items = each.value.enable_items ? each.value.items : null
}
