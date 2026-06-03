locals {
  target_group_names = keys(var.target_groups)
}

locals {
  vpc_sg_map = {
    for idx, name in var.security_group_names : name => {
      vpc_id = var.vpc_ids[var.vpc_names[idx]] 
      tags   = var.security_group_tags[idx]
    }
  }
}