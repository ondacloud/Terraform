variable "name" {
  type = string
}

variable "billing_mode" {
  type = string
}

variable "read_capacity" {
  type = number
}

variable "write_capacity" {
  type = number
}

variable "hash_key" {
  type = string
}

variable "range_key" {
  type = string
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  })) 
}

variable "server_side_encryption" {
  type = object({
    enabled = optional(bool)
    kms_key_arn = optional(any)
  })
  default = null
}

variable "ttl" {
  type = object({
    attribute_name = string
    enabled = bool
  })
  default = null
}

variable "point_in_time_recovery" {
  type = object({
    enabled = bool
  })
  default = null
}

variable "local_secondary_indexes" {
  type = list(object({
    name = string
    range_key = string
    projection_type = string
    non_key_attributes = optional(list(string))
  }))
  default = null
}

variable "global_secondary_indexes" {
  type = list(object({
    name = string
    hash_key = string
    range_key = optional(string)
    projection_type = string
    non_key_attributes = optional(list(string))
    read_capacity = optional(number)
    write_capacity = optional(number)
  }))
  default = null
}

variable "replicas" {
  type = list(object({
    region_name = string
    kms_key_arn = optional(string)
    propagate_tags = optional(bool)
    point_in_time_recovery = optional(object({enabled = bool}))
    consistency_mode = optional(string)
  }))
  default = null
}

variable "items" {
  type = list(object({
    key = string
    value_name = string
    value_type = string
  }))
  default = null
}

variable "tags" {
  type = map(string)
}