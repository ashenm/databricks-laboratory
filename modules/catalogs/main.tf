locals {
  catalog_permissions = merge([for key, catalog in var.catalogs : { for permission in catalog.permissions : join("-", [key, permission.group]) => merge({ catalog = key }, permission) }]...)
  catalog_storages    = { for key, catalog in var.catalogs : key => catalog if catalog.storage_isolation == "isolate" }
}

module "storages" {
  source      = "../storages"
  name_prefix = var.name_prefix
  storages = { for key, catalog in var.catalogs : key => {
    bucket_name        = catalog.storage_root == null ? null : lower(replace(catalog.storage_root, "/s3:\\/\\/(.*)\\//", "$1"))
    create_bucket      = lookup(catalog, "storage_isolation", null) == "isolate"
    force_destroy      = lookup(catalog, "force_destroy", null)
    use_custom_kms_key = lookup(catalog, "use_custom_kms_key", null)
  } }
}

resource "databricks_catalog" "catalogs" {
  for_each       = var.catalogs
  name           = lower(coalesce(each.value.name, replace(join("-", compact([var.name_prefix, each.key])), "-", "_")))
  storage_root   = each.value.storage_root == null ? module.storages.storage_locations[each.key].url : each.value.storage_root
  isolation_mode = "ISOLATED"
}

resource "databricks_grants" "catalogs" {
  for_each = local.catalog_permissions
  catalog  = databricks_catalog.catalogs[each.value.catalog].name

  grant {
    principal  = data.databricks_group.catalogs[each.value.group].display_name
    privileges = each.value.privileges
  }
}

data "databricks_group" "catalogs" {
  for_each     = toset([for key, catalog_permission in local.catalog_permissions : catalog_permission.group])
  display_name = each.key
}
