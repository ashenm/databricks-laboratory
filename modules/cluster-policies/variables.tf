variable "cluster_policies" {
  type = map(object({
    definition            = string
    name                  = optional(string)
    description           = optional(string)
    max_clusters_per_user = optional(number)
    libraries = optional(object({
      pypi = optional(list(object({
        package = string
        repo    = optional(string)
      })))
      maven = optional(list(object({
        coordinates = string
        repo        = optional(string)
        exclusions  = optional(list(string))
      })))
    }))
    permissions = optional(list(object({
      group     = string
      privilege = string
    })))
  }))
}
