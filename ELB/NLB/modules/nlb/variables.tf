variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "nlb_tags" {
  type = map(string)
}

variable "internal" {
  type = bool
}

variable "port" {
  type = number
}

variable "protocol" {
  type = string
}

variable "enable_cross_zone_load_balancing" {
  type = bool
}

variable "listener_target_groups" {
  type = string
}

variable "target_groups" {
  type = list(object({
    name                 = string
    port                 = number
    protocol             = string
    target_type          = string
    deregistration_delay = number

    health_check = object({
      protocol            = string
      path                = string
      port                = number
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
      matcher             = string
    })
  }))
}

variable "enable_target" {
  type = bool
}

variable "ec2_info" {
  type = any
  default = null  
}

variable "targets" {
  type = list(object({
    type              = string
    target_group_name = string
    target_name       = string
    target_port       = number
  }))
}