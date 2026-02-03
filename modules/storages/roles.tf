resource "aws_iam_role" "storages" {
  for_each           = var.storages
  name               = local.storage_role_names[each.key]
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.storages[each.key].json
}

resource "aws_iam_role_policy" "storages" {
  for_each = var.storages
  role     = aws_iam_role.storages[each.key].name
  policy   = data.databricks_aws_unity_catalog_policy.storages[each.key].json
}

resource "aws_iam_role_policy" "auxiliaries" {
  for_each = var.storages
  role     = aws_iam_role.storages[each.key].name
  policy   = data.aws_iam_policy_document.storages[each.key].json
}

data "databricks_aws_unity_catalog_assume_role_policy" "storages" {
  for_each       = var.storages
  aws_account_id = data.aws_caller_identity.current.account_id
  external_id    = one(databricks_storage_credential.storages[each.key].aws_iam_role.*.external_id)
  role_name      = local.storage_role_names[each.key]
}

data "databricks_aws_unity_catalog_policy" "storages" {
  for_each       = var.storages
  aws_account_id = data.aws_caller_identity.current.account_id
  bucket_name    = local.storage_bucket_names[each.key]
  role_name      = local.storage_role_names[each.key]
}
