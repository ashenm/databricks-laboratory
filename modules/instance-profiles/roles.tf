resource "aws_iam_role" "instance_profiles" {
  for_each           = var.instance_profiles
  name               = upper("${var.name_prefix}-ec2-${local.instance_profile_aliases[each.key]}")
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy" "instance_profiles" {
  for_each = merge([for key, instance_profile in var.instance_profiles : { for idx, policy in instance_profile.policies : "${key}-${idx}" => merge({ key = key }, policy) }]...)
  role     = aws_iam_role.instance_profiles[each.value.key].name
  name     = each.value.name
  policy   = each.value.policy
}

resource "aws_iam_role_policy" "delegations" {
  name   = "AllowInstanceProfilesRoleDelegations"
  role   = data.aws_iam_role.databricks.name
  policy = data.aws_iam_policy_document.delegations.json
}

data "aws_iam_role" "databricks" {
  name = upper("${var.name_prefix}-databricks")
}
