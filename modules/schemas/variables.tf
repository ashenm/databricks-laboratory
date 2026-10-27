variable "schemas" {
  type = map(object({
    name          = optional(string)
    catalog_name  = string
    force_destroy = optional(bool, false)
    storage_root  = optional(string)
    permissions = optional(list(object({
      group      = string
      privileges = list(string)
    })))
    owner = optional(string, null)
  }))
}
