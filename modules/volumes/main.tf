resource "databricks_volume" "volumes" {
  for_each     = var.volumes
  name         = lower(coalesce(each.value.name, replace(each.key, "-", "_")))
  catalog_name = data.databricks_catalog.volumes[each.value.catalog_name].name
  schema_name  = each.value.schema_name
  volume_type  = "MANAGED"
}

resource "databricks_grants" "volumes" {
  for_each = { for key, value in var.volumes : key => value if length(coalesce(value.permissions, [])) != 0 }
  volume   = databricks_volume.volumes[each.key].id

  dynamic "grant" {
    for_each = each.value.permissions

    content {
      principal  = data.databricks_group.volumes[grant.value.group].display_name
      privileges = grant.value.privileges
    }
  }
}

data "databricks_catalog" "volumes" {
  for_each = toset([for key, volume in var.volumes : volume.catalog_name])
  name     = each.key
}

data "databricks_schema" "volumes" {
  for_each = toset([for key, volume in var.volumes : join(".", [volume.catalog_name, volume.schema_name])])
  name     = each.key
}

data "databricks_group" "volumes" {
  for_each     = toset(flatten([for key, volume in var.volumes : [for permission in volume.permissions : permission.group]]))
  display_name = each.key
}
