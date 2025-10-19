locals {
  types = {
    for item in flatten([
      for s in var.types : [
        for az_index, az in var.azs : {
          key     = "${s.type}-${az_index}"
          type    = s.type
          sn_cidr = s.sn_cidrs[az_index]
          az      = az

          sn_tags = {
            for k, v in s.sn_tags :
            k => replace(v, "$1", substr(az, -1, 1))
          }

          rtb_tags = {
            for k, v in s.rtb_tags :
            k => replace(v, "$1", substr(az, -1, 1))
          }

          igw_tags = s.igw_tags

          natgw_tags = s.natgw_tags != null ? {
            for k, v in s.natgw_tags :
            k => replace(v, "$1", substr(az, -1, 1))
          } : {}
        }
      ]
    ]) : item.key => item
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