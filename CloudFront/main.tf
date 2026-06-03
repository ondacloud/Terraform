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

module "s3" {
  depends_on = [ module.kms ]

  source = "./modules/s3"

  for_each = local.s3s

  name                   = each.key
  tags                   = each.value.tags
  enable_objects         = each.value.enable_objects
  objects                = each.value.objects
  enable_bucket_kms      = each.value.enable_bucket_kms
  enable_object_kms      = each.value.enable_object_kms
  server_side_encryption = each.value.enable_bucket_kms || each.value.enable_object_kms ? each.value.server_side_encryption : "AES256"
  kms_arn                = module.kms[each.value.kms_key_name].kms_arn
  # kms_arn                = null
}

module "cloudfront" {
  depends_on = [ module.s3 ]

  source = "./modules/cloudfront"

  for_each = local.cloudfronts
  
  tags                           = each.value.tags
  origin_path                    = each.value.origin_path
  default_root_object            = each.value.default_root_object
  enable_waf                     = each.value.enable_waf
  # waf_id                         = module.waf[each.value.waf_name].waf_arn
  waf_id                         = null
  
  s3_bucket_id                   = module.s3[each.value.s3_bucket_name].s3_bucket_id
  s3_bucket_arn                  = module.s3[each.value.s3_bucket_name].s3_bucket_arn
  s3_bucket_regional_domain_name = module.s3[each.value.s3_bucket_name].s3_bucket_regional_domain_name
}