locals {
  instance_profile_aliases = { for key, instance_profile in var.instance_profiles : key => coalesce(instance_profile.name, key) }
}

resource "aws_iam_instance_profile" "instance_profiles" {
  for_each = var.instance_profiles
  name     = lower("${var.name_prefix}-${local.instance_profile_aliases[each.key]}")
  role     = aws_iam_role.instance_profiles[each.key].name
}

resource "databricks_instance_profile" "instance_profiles" {
  for_each             = var.instance_profiles
  instance_profile_arn = aws_iam_instance_profile.instance_profiles[each.key].arn
}
