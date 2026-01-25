output "cluster_policies" {
  value = { for key, value in var.cluster_policies : key => {
    id = databricks_cluster_policy.cluster_policies[key].id
  } }
}
