resource "databricks_cluster_policy" "cluster_policies" {
  for_each              = var.cluster_policies
  name                  = lower(coalesce(each.value.name, replace(each.key, "-", "_")))
  description           = each.value.description
  definition            = jsonencode(each.value.definition)
  max_clusters_per_user = each.value.max_clusters_per_user

  dynamic "libraries" {
    for_each = coalesce(each.value.libraries, [])

    content {
      dynamic "pypi" {
        for_each = coalesce(libraries.value.pypi, [])

        content {
          package = pypi.value.package
          repo    = pypi.value.repo
        }
      }

      dynamic "maven" {
        for_each = coalesce(libraries.value.maven, [])

        content {
          coordinates = maven.value.coordinates
          repo        = maven.value.repo
          exclusions  = maven.value.exclusions
        }
      }
    }
  }
}

resource "databricks_permissions" "cluster_policies" {
  for_each          = var.cluster_policies
  cluster_policy_id = databricks_cluster_policy.cluster_policies[each.key].policy_id

  dynamic "access_control" {
    for_each = coalesce(each.value.permissions, [])

    content {
      group_name       = data.databricks_group.cluster_policies[access_control.value.group].display_name
      permission_level = access_control.value.privilege
    }
  }
}

data "databricks_group" "cluster_policies" {
  for_each     = toset(flatten([for key, cluster_policy in var.cluster_policies : [for permission in cluster_policy.permissions : permission.group]]))
  display_name = each.key
}
