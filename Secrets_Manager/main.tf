module "secrets_manager" {
  source = "./modules/secrets-manager"

  for_each = local.secrets_managers

  name = each.key
  tags = each.value.tags

  secret_values = (
    can(each.value.enable_values) ? {
      DB_USER     = module.rds[each.value.rds_name].rds_user_name
      DB_PASSWORD = module.rds[each.value.rds_name].rds_user_password
      DB_ADDRESS  = module.rds[each.value.rds_name].rds_address
      DB_PORT     = module.rds[each.value.rds_name].rds_port
      DB_NAME     = module.rds[each.value.rds_name].rds_db_name
    }
    : {}
  )
}