resource "aws_iam_role" "externals" {
  name               = local.aws_iam_role_name
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.externals.json
}

resource "aws_iam_role_policy" "externals" {
  role   = aws_iam_role.externals.id
  policy = data.aws_iam_policy_document.externals.json
}
