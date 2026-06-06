variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "kms_key_id" {
  type = string
}

variable "create_log_stream" {
  type = bool
  default = false
}

variable "log_stream_names" {
  type = list(string)
}