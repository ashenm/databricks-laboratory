output "catalogs" {
  value = { for key, value in var.catalogs : key => {
    id           = databricks_catalog.catalogs[key].id
    name         = databricks_catalog.catalogs[key].name
    storage_root = databricks_catalog.catalogs[key].storage_root
  } }
}
