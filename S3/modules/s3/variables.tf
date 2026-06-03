variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "enable_objects" {
  type = bool
  default = false
}

variable "objects" {
  type = list(object({
    key          = string
    source       = string
    content_type = optional(string)
  }))
  default = []
}

variable "enable_bucket_kms" {
  type = bool
  default = false
}

variable "enable_object_kms" {
  type = bool
  default = false
}

variable "server_side_encryption" {
  type = string
}

variable "kms_arn" {
  type = string
}