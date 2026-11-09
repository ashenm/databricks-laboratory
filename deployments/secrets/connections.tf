resource "databricks_connection" "externals" {
  name            = "aws-secrets-manager"
  connection_type = "AWS_SECRETS_MANAGER"
  owner           = var.owner

  options = {
    aws_region = data.aws_region.current.region
    credential = databricks_credential.externals.name
  }
}
