variable "tags" {
  type = map(string)
}

variable "s3_bucket_id" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "s3_bucket_regional_domain_name" {
  type = string
}

variable "enable_waf" {
  type    = bool
  default = false
}

variable "waf_id" {
  type = string
  default = null
}

variable "origin_path" {
  type = string
}

variable "default_root_object" {
  type = string
}