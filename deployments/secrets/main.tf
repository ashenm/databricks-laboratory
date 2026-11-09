resource "databricks_schema" "secrets" {
  catalog_name = var.catalog_name
  owner        = var.owner
  name         = "secrets"
}

resource "databricks_workspace_setting_v2" "externals" {
  name        = "uc_external_secrets"
  boolean_val = { value = true }
}

resource "terraform_data" "externals" {
  triggers_replace = {
    schema     = databricks_schema.secrets.id
    connection = databricks_connection.externals.name
  }

  input = {
    schema     = databricks_schema.secrets.id
    connection = databricks_connection.externals.name
    host       = data.databricks_current_user.current.workspace_url
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/schema-secret-storage.py create --schema ${self.input.schema} --connection-name ${self.input.connection}"

    environment = {
      DATABRICKS_HOST = self.input.host
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "python3 ${path.module}/schema-secret-storage.py delete --schema ${self.input.schema}"

    environment = {
      DATABRICKS_HOST = self.input.host
    }
  }
}

resource "time_sleep" "extenrals" {
  # allow databricks to sync secrets prior referencing
  depends_on      = [databricks_credential.externals]
  create_duration = "30s"
}

data "databricks_current_user" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
