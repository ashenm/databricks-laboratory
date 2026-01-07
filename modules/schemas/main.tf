locals {
  schema_catalogs    = toset([for key, schema in var.schemas : schema.catalog_name])
  schema_permissions = merge([for key, schema in var.schemas : { for permission in schema.permissions : join("-", [key, permission.group]) => merge({ schema = key }, permission) }]...)
}

resource "databricks_schema" "schemas" {
  for_each     = var.schemas
  name         = lower(coalesce(each.value.name, replace(each.key, "-", "_")))
  catalog_name = data.databricks_catalog.schemas[each.value.catalog_name].name
  storage_root = each.value.storage_root
}

resource "databricks_grants" "schemas" {
  for_each = local.schema_permissions
  schema   = databricks_schema.schemas[each.value.schema].id

  grant {
    principal  = data.databricks_group.schemas[each.value.group].display_name
    privileges = each.value.privileges
  }
}

data "databricks_catalog" "schemas" {
  for_each = local.schema_catalogs
  name     = each.key
}

data "databricks_group" "schemas" {
  for_each     = toset([for key, schema_permission in local.schema_permissions : schema_permission.group])
  display_name = each.key
}
