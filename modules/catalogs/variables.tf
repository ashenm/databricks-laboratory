variable "name_prefix" {
  type    = string
  default = null
}

variable "catalogs" {
  type = map(object({
    name              = optional(string)
    storage_root      = optional(string)
    storage_isolation = optional(string)
    permissions = list(object({
      group      = string
      privileges = list(string)
    }))
    use_custom_kms_key = optional(bool)
  }))
}
