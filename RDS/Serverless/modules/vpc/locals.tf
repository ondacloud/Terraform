locals {
  types = {
    for item in flatten([
      for s in var.types : [
        for az_index, az in var.azs :
        {
          key         = "${s.type}-${az_index}" 
          type        = s.type
          sn_cidr     = s.sn_cidrs[az_index] 
          az          = az
          sn_name     = replace(s.sn_name, "$1", substr(az, -1, 1)) 
          rtb_name    = replace(s.rtb_name, "$1", substr(az, -1, 1)) 
           
          igw_name   = s.igw_name != null ? s.igw_name : null
          natgw_name = (
            s.natgw_name != null ?
            replace(s.natgw_name, "$1", substr(az, -1, 1)) :
            null
          )
        }
      ]
    ]) : item.key => item
  }
}

locals {
  natgw_types = {
    for k, v in local.types :
    k => v
    if v.type == "public" && v.natgw_name != null && var.enable_natgw
  }
}

locals {
  shared_rtb_types = ["public", "protect"]

  rtbs_to_create = merge(
    {
      for t, group in {
        for k, v in local.types :
        v.type => v... if contains(local.shared_rtb_types, v.type)
      } :
      t => group[0]
    },
    {
      for k, v in local.types :
      k => v
      if !contains(local.shared_rtb_types, v.type)
    }
  )
}
