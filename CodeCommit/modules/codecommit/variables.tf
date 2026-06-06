variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "kms_key_id" {
  type = string
}