locals {
  parameter = "demo"
}

locals {
  secrets_managers = {
    db = {
      enable_values = true
      name          = "${local.parameter}-rds-secrets"
      tags          = {Name = "${local.parameter}-rds-secrets"}
      rds_name      = "${local.parameter}-rds-instance"
    }
  }
}
