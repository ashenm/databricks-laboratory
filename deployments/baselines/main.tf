provider "databricks" {
  host = var.databricks_workspace_url
}

resource "databricks_global_init_script" "baselines" {
  source  = "${path.module}/artifacts/ini.sh"
  name    = "environment-baselines"
  enabled = true
}
