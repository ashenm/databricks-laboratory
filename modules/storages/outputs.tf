output "storage_credentials" {
  value = { for key, value in var.storages : key => {
    name                     = databricks_storage_credential.storages[key].name
    id                       = databricks_storage_credential.storages[key].id
    aws_iam_role_arn         = one(databricks_storage_credential.storages[key].aws_iam_role.*.role_arn)
    aws_iam_role_external_id = one(databricks_storage_credential.storages[key].aws_iam_role.*.external_id)
  } }
}

output "storage_locations" {
  value = { for key, value in var.storages : key => {
    name = databricks_external_location.storages[key].name
    id   = databricks_external_location.storages[key].id
    url  = databricks_external_location.storages[key].url
  } }
}
