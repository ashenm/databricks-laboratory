resource "databricks_credential" "externals" {
  name    = lower(var.name_prefix)
  purpose = "SERVICE"
  owner   = var.owner

  aws_iam_role {
    role_arn = aws_iam_role.externals.arn
  }

  depends_on = [aws_iam_role_policy.externals]
}
