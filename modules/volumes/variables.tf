variable "volumes" {
  type = map(object({
    name          = optional(string)
    catalog_name  = string
    schema_name   = string
    force_destroy = optional(bool)
    permissions = optional(list(object({
      group      = string
      privileges = list(string)
    })))
  }))
}
