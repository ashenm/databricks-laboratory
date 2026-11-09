data "aws_iam_policy_document" "externals" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.externals.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = ["arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:*"]
  }
}

data "databricks_aws_unity_catalog_assume_role_policy" "externals" {
  aws_account_id = data.aws_caller_identity.current.account_id
  role_name      = local.aws_iam_role_name
  external_id    = var.databricks_account_id
}
