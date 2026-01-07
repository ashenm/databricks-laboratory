variable "name_prefix" {
  type    = string
  default = null
}

variable "storages" {
  type = map(object({
    bucket_name        = string
    create_bucket      = optional(bool)
    force_destroy      = optional(bool)
    use_custom_kms_key = optional(bool)
  }))
}
