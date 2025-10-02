variable "parameter" {
  type = string
}

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

variable "default_rtb_name" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "types" {
  type = list(object({
    type     = string
    sn_name  = string
    sn_cidrs = list(string)
    rtb_name = string
    
    igw_name   = optional(string) 
    natgw_name = optional(string)
  }))
}