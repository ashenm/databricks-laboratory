module "services" {
  source = "./services"
  schema = databricks_schema.main.id
}

resource "databricks_schema" "main" {
  catalog_name = data.databricks_catalog.main.id
  owner        = var.owner
  name         = "ai"
}

data "databricks_catalog" "main" {
  name = var.catalog_name
}
