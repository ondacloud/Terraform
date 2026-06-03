variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "stage_name" {
  type = string
}

variable "enable_api_key" {
  type = bool
}

variable "api_key_name" {
  type = string
}

variable "api_key_tags" {
  type = map(string)
}

variable "usage_plan_name" {
  type = string
}

variable "usage_plan_tags" {
  type = map(string)
}

variable "enable_throttle_settings" {
  type    = bool
  default = false
}

variable "rate_limit" {
  type = number
}

variable "burst_limit" {
  type = number
}

variable "api_maps" {
  type = map(any)
}

variable "enable_lambda" {
  type = bool
}

variable "lambda_name" {
  type = string
}

variable "lambda_invoke_arn" {
  type = string
  default = null
}

variable "service_arn" {
  type    = string
  default = null
}

variable "iam_role_name" {
  type = string
}

variable "iam_role_tags" {
  type = map(string)
}

variable "iam_policies" {
  type = list(string)
}