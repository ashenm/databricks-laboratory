locals {
  aws_iam_role_name = upper(var.name_prefix)
  configs           = yamldecode(file("${path.module}/configs.yaml"))
  secrets           = lookup(local.configs, "secrets", {})
}
