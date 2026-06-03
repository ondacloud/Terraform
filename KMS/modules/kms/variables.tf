variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "alias_name" {
  type = string
}

variable "key_usage" {
  type = string
}

variable "deletion_window_in_days" {
  type = number
}

variable "statements" {
  type = list(object({
    sid    = optional(string)
    effect = string

    principals = optional(object({
      type        = string
      identifiers = list(string)
    }))

    actions   = list(string)
    resources = list(string)

    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
}