module "secrets_manager" {
  depends_on = [ module.rds ]

  source = "./modules/secrets-manager"

  for_each = local.secrets_managers

  name = each.value.name
  tags = each.value.tags

  secret_values = (
    each.value.enable_values ? {
      RDS_DB_USER     = module.rds[each.value.rds_name].rds_user_name
      RDS_DB_PASSWORD = module.rds[each.value.rds_name].rds_user_password
      RDS_DB_ADDRESS  = module.rds[each.value.rds_name].rds_address
      RDS_DB_PORT     = module.rds[each.value.rds_name].rds_port
      RDS_DB_NAME     = module.rds[each.value.rds_name].rds_db_name
    }
    : {}
  )
}