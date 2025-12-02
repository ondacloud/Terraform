variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "image_tag_mutability" {
  type = string
}

variable "force_delete" {
  type    = bool
  default = false
}

variable "scan_images_on_push" {
  type    = bool
  default = false
}

variable "encryption_configuration" {
  type = object({
    encryption_type = optional(string)
    kms_key         = optional(any)
  })
  default = null
}

variable "image_tag_mutability_exclusion_filter" {
  type = list(object({
    filter      = string
    filter_type = string
  }))
  default = []
}