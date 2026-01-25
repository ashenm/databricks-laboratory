locals {
  unity_catalog_bucket_name = lower("${var.name_prefix}-unity-catalog")
  configs                   = merge([for filepath in fileset("${path.module}/config", "*.yaml") : yamldecode(file("${path.module}/config/${filepath}"))]...)

  clusters = { for key, value in lookup(local.configs, "clusters", {}) : key => merge(value, {
    instance_profile_arn = lookup(value, "instance_profile", null) != null ? module.instance_profiles.instance_profiles[value.instance_profile].id : null
  }) }

  instance_profile_policies = {
    cloudwatch_agent_serverpolicy = data.aws_iam_policy.cloudwatch_agent_serverpolicy.policy
  }

  instance_profiles = { for key, value in lookup(local.configs, "instance_profiles", {}) : key => merge(value, {
    policies = [for idx, policy in value.policies : merge(policy, { policy = local.instance_profile_policies[policy.policy] })]
  }) }
}

module "catalogs" {
  source      = "../../../modules/catalogs"
  catalogs    = lookup(local.configs, "catalogs", {})
  name_prefix = var.name_prefix
}

module "schemas" {
  source     = "../../../modules/schemas"
  schemas    = lookup(local.configs, "schemas", {})
  depends_on = [module.catalogs]
}

module "instance_profiles" {
  source            = "../../../modules/instance-profiles"
  instance_profiles = local.instance_profiles
  name_prefix       = var.name_prefix
}

module "clusters" {
  source      = "../../../modules/clusters"
  clusters    = local.configs.clusters
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
