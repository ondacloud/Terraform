variable "az_override" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "enable_igw" {
  type = string
}

variable "enable_natgw" {
  type = string
}

variable "default_rtb_tags" {
  type = map(string)
}

variable "default_sg_tags" {
  type = map(string)
}

variable "vpc_name" {
  type = string
}

variable "vpc_tags" {
  type = map(string)
}

variable "vpc_cidr" {
  type = string
}

variable "types" {
  type = list(object({
    type     = string
    sn_cidrs = list(string)
    sn_tags  = map(string)
    rtb_tags = map(string)

    igw_tags   = optional(map(string))
    natgw_tags = optional(map(string))
  }))
}