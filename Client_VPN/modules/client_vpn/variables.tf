variable "vpc_id" {
  type = string
}

variable "targets" {
  type = map(object({
    subnet_id = string
    destination_cidr_block = string
  }))
}

variable "tags" {
  type = map(string)
}

variable "create_certificates" {
  type = bool
  default = false
}

variable "certificate_file_path" {
  type = string
}

variable "algorithm" {
  type = string
}

variable "rsa_bits" {
  type = number
}

variable "certificate" {
  type = map(object({
    common_name  = string
    organization = optional(string)
    dns_names = optional(list(string))
    validity_period_hours = optional(number)
    is_ca_certificate = optional(bool)
  }))
}

variable "client_cidr_block" {
  type = string
}

variable "vpn_port" {
  type = number
}

variable "split_tunnel" {
  type = bool
}

variable "self_service_portal" {
  type = bool
}

variable "dns_servers" {
  type = list(string)
}

variable "session_timeout_hours" {
  type = number
}

variable "disconnect_on_session_timeout" {
  type = bool
  default = false
}

variable "authentication_type" {
  type = string
}

variable "enable_connection_logging" {
  type = bool
  default = false
}

variable "enable_client_login_banner" {
  type = bool
  default = false
}

variable "client_login_banner_text" {
  type = string
}

variable "target_network_cidr" {
  type = string
}

variable "authorize_all_groups" {
  type = bool
  default = true
}

variable "enable_vpn_route" {
  type = bool
  default = false
}

variable "cloudwatch_log_group_name" {
  type = string
}

variable "cloudwatch_log_stream_name" {
  type = string
}

variable "security_group_name" {
  type  = string
}

variable "security_group_tags" {
  type = map(string)
}

variable "ingress_ports" {
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_block       = optional(string)
    prefix_list_id   = optional(string)
    security_groups  = optional(list(string))
  }))
}

variable "egress_ports" {
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_block       = optional(string)
    prefix_list_id   = optional(string)
    security_groups  = optional(list(string))
  }))
}