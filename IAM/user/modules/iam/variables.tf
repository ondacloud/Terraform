variable "user_name" {
  type = string
}

variable "user_tags" {
  type    = map(string)
}

variable "service_name" {
  type = string
}

variable "statements" {
  type = list(object({
    sid        = optional(string, null)
    effect     = string
    actions    = list(string)
    resources  = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

variable "enable_inline_policy" {
  type = bool
}

variable "inline_policy_name" {
  type = string
}

variable "enable_custom_policy" {
  type    = bool
}

variable "policy_name" {
  type    = string
}

variable "policy_tags" {
  type    = map(string)
}

variable "enable_managed_policy" {
  type    = bool
}

variable "managed_policy_arns" {
  type    = list(string)
}