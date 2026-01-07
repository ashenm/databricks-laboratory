locals {
  unity_catalog_bucket_name = lower("${var.name_prefix}-unity-catalog")
  configs                   = merge([for filepath in fileset("${path.module}/config", "*.yaml") : yamldecode(file("${path.module}/config/${filepath}"))]...)
}

module "clusters" {
  source      = "../../../modules/clusters"
  clusters    = local.configs.clusters
  name_prefix = var.name_prefix
}

# module "cluster_policies" {
#   source   = "../../../modules/cluster-policies"
#   policies = []
# }

module "catalogs" {
  source      = "../../../modules/catalogs"
  catalogs    = lookup(local.configs, "catalogs", {})
  name_prefix = var.name_prefix
}

module "schemas" {
  source  = "../../../modules/schemas"
  schemas = lookup(local.configs, "schemas", {})
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
