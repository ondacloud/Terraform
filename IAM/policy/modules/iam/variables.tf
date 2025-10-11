variable "policy_name" {
  type = string
}

variable "statements" {
  type = list(object({
    sid       = optional(string)
    effect    = string
    actions   = list(string)
    resources = list(string)
    
    conditions = optional(list(object({
      test       = string
      variable   = string
      values     = list(string)
    })), [])
  }))
}

variable "policy_tags" {
  type = map(string)
}