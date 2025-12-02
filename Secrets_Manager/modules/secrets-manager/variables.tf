variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "secret_values" {
  type = map(any)
}