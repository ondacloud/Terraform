variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "enable_kms" {
  type = bool
  default = false
}

variable "kms_key_id" {
  type = string
}