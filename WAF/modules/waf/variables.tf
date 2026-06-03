variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "metric_name" {
  type = string
}

variable "enable_cloudfront" {
  type = bool
  default = false
}

variable "alb_arn" {
  type    = string
  default = null
}

variable "enable_managed" {
  type    = bool
  default = true
}

variable "managed_rules" {
  type = list(object({
    enabled    = bool
    name       = string
    vendor     = string
    rule_group = string
  }))
  default = []
}

variable "enable_custom" {
  type    = bool
  default = true
}

variable "custom_rules" {
  type = list(object({
    enabled = bool
    name    = string
    method  = string
    field   = string
    matches = list(string)
    operator = string
    negate  = bool
    action  = string
  }))
  default = []
}

variable "enable_logging" {
  type = bool
  default = false
}

variable "log_destination_arns" {
  type    = list(string)
  default = []
}