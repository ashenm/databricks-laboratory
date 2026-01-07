locals {
  cluster_permissions = merge([for key, cluster in var.clusters : { for permission in lookup(cluster, "permissions", []) : join("-", [key, permission.group]) => merge({ cluster = key }, permission) }]...)
}

resource "databricks_cluster" "clusters" {
  for_each            = var.clusters
  num_workers         = each.value.num_workers
  cluster_name        = coalesce(each.value.name, upper(join("-", compact([var.name_prefix, each.key]))))
  spark_version       = coalesce(each.value.spark_version, data.databricks_spark_version.lts.id)
  runtime_engine      = coalesce(each.value.runtime_engine, "STANDARD")
  node_type_id        = coalesce(each.value.node_type_id, data.databricks_node_type.smallest.id)
  driver_node_type_id = each.value.driver_node_type_id
  data_security_mode  = coalesce(each.value.data_security_mode, "USER_ISOLATION")

  autoscale {
    min_workers = coalesce(each.value.autoscale_min_workers, 1)
    max_workers = coalesce(each.value.autoscale_max_workers, 1)
  }

  autotermination_minutes = coalesce(each.value.autotermination_minutes, 30)
  no_wait                 = each.value.no_wait
  custom_tags             = each.value.custom_tags
}

resource "databricks_permissions" "clusters" {
  for_each   = local.cluster_permissions
  cluster_id = databricks_cluster.clusters[each.value.cluster].id

  access_control {
    group_name       = data.databricks_group.clusters[each.value.group].display_name
    permission_level = each.value.privilege
  }
}

data "databricks_group" "clusters" {
  for_each     = toset([for key, cluster_permission in local.cluster_permissions : cluster_permission.group])
  display_name = each.key
}

data "databricks_spark_version" "lts" {
  long_term_support = true
}

data "databricks_node_type" "smallest" {
  local_disk = true
}
