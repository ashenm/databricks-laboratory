output "aws_iam_role_name" {
  value = aws_iam_role.externals.name
}

output "secrets" {
  value = { for key, value in local.secrets : key => {
    id          = data.databricks_secret_uc.externals[key].full_name
    name        = data.databricks_secret_uc.externals[key].name
    expire_time = data.databricks_secret_uc.externals[key].expire_time
  } }
}
