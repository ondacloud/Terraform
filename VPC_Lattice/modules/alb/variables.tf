variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "alb_tags" {
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

variable "default_action" {
  type = any
}

variable "enable_listener_rules" {
  type = bool
  default = false
}

variable "listener_rules" {
  type = any
}

variable "target_groups" {
  type = list(object({
    name                 = string
    port                 = number
    protocol             = string
    target_type          = string
    deregistration_delay = number
    tags                 = optional(map(string))

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

variable "security_group_name" {
  type = string
}

variable "security_group_tags" {
  type = map(string)
}

variable "ingress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
  }))
}

variable "egress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
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