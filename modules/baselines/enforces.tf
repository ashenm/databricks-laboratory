resource "terraform_data" "policy_compliance_team" {
  count = local.__count_team_policies

  triggers_replace = [
    databricks_cluster_policy.job_compute_team[count.index].id,
    sha256(databricks_cluster_policy.job_compute_team[count.index].policy_family_definition_overrides),
    filesha256("${path.module}/enforce.py")
  ]

  provisioner "local-exec" {
    working_dir = path.module
    command     = "python3 enforce.py ${databricks_cluster_policy.job_compute_team[count.index].id}"
    environment = { DATABRICKS_HOST = data.databricks_current_user.current.workspace_url }
  }

  depends_on = [databricks_cluster_policy.job_compute_team]
}

resource "terraform_data" "policy_compliance_user" {
  count = local.__count_user_policies

  triggers_replace = [
    databricks_cluster_policy.job_compute_user[count.index].id,
    sha256(databricks_cluster_policy.job_compute_user[count.index].policy_family_definition_overrides),
    filesha256("${path.module}/enforce.py")
  ]

  provisioner "local-exec" {
    working_dir = path.module
    command     = "python3 enforce.py ${databricks_cluster_policy.job_compute_user[count.index].id}"
    environment = { DATABRICKS_HOST = data.databricks_current_user.current.workspace_url }
  }

  depends_on = [databricks_cluster_policy.job_compute_user]
}
