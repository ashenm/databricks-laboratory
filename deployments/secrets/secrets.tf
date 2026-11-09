resource "databricks_grants" "externals" {
  for_each = local.secrets
  secret   = data.databricks_secret_uc.externals[each.key].full_name

  dynamic "grant" {
    for_each = each.value.grants

    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

data "databricks_secret_uc" "externals" {
  for_each   = local.secrets
  full_name  = "${databricks_schema.secrets.id}.${each.key}"
  depends_on = [time_sleep.extenrals]
}
