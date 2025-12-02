locals {
  parameter = "demo"
}

locals {
  secrets_managers = {
    "${local.parameter}-secrets" = {
      tags = {
        Name = "${local.parameter}-secrets"
      }
      
      rds_name      = "${local.parameter}-db-instance"
      enable_values = false
    }
  }
}