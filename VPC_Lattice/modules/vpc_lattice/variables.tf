variable "vpc_names" {
  type = list(string)
}

variable "vpc_ids" {
  type = map(string)
}

variable "service_network_name" {
  type = string
}

variable "service_network_auth_type" {
  type = string
}

variable "service_network_tags" {
  type = map(string)
}

variable "service_network_vpc_tags" {
  type = map(string)
}

variable "service_name" {
  type = string
}

variable "service_auth_type" {
  type = string
}

variable "service_tags" {
  type = map(string)
}

variable "service_association_tags" {
  type = map(string)
}

variable "alb_arn" {
  type = string
}

variable "security_group_names" {
  type = list(string)
}

variable "security_group_tags" {
  type = list(map(string))
}

variable "ingress_ports" {
  type = list(object({
    from_port      = number
    to_port        = number
    protocol       = string
    cidr_block     = optional(string)
    prefix_list_id = optional(string)
    security_groups = optional(list(string))
  }))
}

variable "egress_ports" {
  type = list(object({
    from_port      = number
    to_port        = number
    protocol       = string
    cidr_block     = optional(string)
    prefix_list_id = optional(string)
    security_groups = optional(list(string))
  }))
}

variable "target_groups" {
  type = map(object({
    name = string
    type = string
    config = object({
      port                           = optional(number)
      protocol                       = optional(string)
      vpc_identifier_name            = optional(string)
      ip_address_type                = optional(string)
      protocol_version               = optional(string)
      lambda_event_structure_version = optional(string)
    })
    health_check = optional(object({
      enabled                       = optional(bool)
      health_check_interval_seconds = number
      health_check_timeout_seconds  = number
      healthy_threshold_count       = number
      path                          = string
      port                          = number
      protocol                      = string
      protocol_version              = optional(string)
      unhealthy_threshold_count     = number
      matcher                       = string
    }))
    tags = map(string)
  }))
}

variable "listener_name" {
  type = string
}

variable "listener_protocol" {
  type = string
}

variable "listener_port" {
  type = number
}

variable "default_forward_target_groups" {
  type = list(object({
    target_group_name = string
    weight            = number
  }))
}

variable "listener_rules" {
  type = list(object({
    name              = string
    priority          = number
    weight            = number
    header_name       = string
    header_value      = string
    target_group_name = string
  }))
}

variable "enable_attach_target" {
  type = bool
}

variable "targets" {
  type = list(object({
    target_group_name = string
    target_name       = string
    target_port       = number
  }))
}

variable "target_info" {
  type = list(string)
}