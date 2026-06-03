resource "aws_dynamodb_table" "order-table" {
  name           = var.name
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = var.hash_key
  range_key      = var.range_key
  
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "server_side_encryption" {
    for_each = var.server_side_encryption == null ? [] : [var.server_side_encryption]
    content {
      enabled     = server_side_encryption.value.enabled
      kms_key_arn = try(server_side_encryption.value.kms_key_arn, null)
    }
  }

  dynamic "ttl" {
    for_each = var.ttl == null ? [] : [var.ttl]
    content {
      enabled = ttl.value.enabled
      attribute_name = ttl.value.attribute_name
    }
  }
  
  dynamic "point_in_time_recovery" {
    for_each = var.point_in_time_recovery == null ? [] : [var.point_in_time_recovery]
    content {
      enabled = point_in_time_recovery.value.enabled
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes == null ? [] : var.local_secondary_indexes
    content {
      name            = local_secondary_index.value.name
      range_key       = local_secondary_index.value.range_key
      projection_type = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? lookup(local_secondary_index.value, "non_key_attributes", null) : null
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes == null ? [] : var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      projection_type = global_secondary_index.value.projection_type
      range_key       = lookup(global_secondary_index.value, "range_key", null)
      read_capacity  = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", null) : null
      write_capacity = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", null) : null
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? lookup(global_secondary_index.value, "non_key_attributes", null) : null
    }
  }

  dynamic "replica" {
    for_each = var.replicas == null ? [] : var.replicas
    content {
      region_name            = replica.value.region_name
      kms_key_arn            = lookup(replica.value, "kms_key_arn", null)
      propagate_tags         = lookup(replica.value, "propagate_tags", null)
      point_in_time_recovery = lookup(replica.value, "point_in_time_recovery", null)
      consistency_mode       = try(replica.value.consistency_mode, null)
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [global_secondary_index, read_capacity, write_capacity]
  }
}

resource "aws_dynamodb_table_item" "this" {
  for_each = var.items == null ? {} : { for idx, item in var.items : idx => item }
  table_name = aws_dynamodb_table.this.name
  hash_key   = aws_dynamodb_table.this.hash_key

  item = jsonencode({
    for k, v in each.value :
    k => (
      can(tonumber(v))
      ? { "N" = tostring(v) }
      : { "S" = v }
    )
  })
}