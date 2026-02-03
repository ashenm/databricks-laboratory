variable "name_prefix" {
  type    = string
  default = null
}

variable "storages" {
  type = map(object({
    bucket_name   = optional(string)
    force_destroy = optional(bool)
  }))
}
