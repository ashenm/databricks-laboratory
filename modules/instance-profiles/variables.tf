variable "name_prefix" {
  type = string
}

variable "instance_profiles" {
  type = map(object({
    name = optional(string)
    policies = list(object({
      name   = optional(string)
      policy = string
    }))
  }))
}
