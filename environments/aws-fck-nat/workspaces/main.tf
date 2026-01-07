locals {
  unity_catalog_bucket_name = lower("${var.name_prefix}-unity-catalog")
  configs                   = merge([for filepath in fileset("${path.module}/config", "*.yaml") : yamldecode(file("${path.module}/config/${filepath}"))]...)
}

module "catalogs" {
  source      = "../../../modules/catalogs"
  catalogs    = lookup(local.configs, "catalogs", {})
  name_prefix = var.name_prefix
}

resource "databricks_default_namespace_setting" "main" {
  namespace {
    value = module.catalogs.catalogs["main"].name
  }
}

resource "databricks_disable_legacy_access_setting" "main" {
  disable_legacy_access {
    value = true
  }
}
