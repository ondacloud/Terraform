variable "vpc_id" {
  type = string
}

variable "target_groups" {
  type = list(object({
    name                 = string
    port                 = number
    protocol             = string
    target_type          = string
    deregistration_delay = number
    tags                 = map(string)

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

variable "enable_attach_target" {
  type = bool
}

variable "target_info" {
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