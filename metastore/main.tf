provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Owner = "hewagallage.gunaratne@databricks.com"
    }
  }
}

provider "databricks" {
  host = "https://accounts.cloud.databricks.com"
}

resource "databricks_metastore" "main" {
  name          = var.metastore_name
  force_destroy = true
  region        = var.aws_region

  lifecycle {
    ignore_changes = [owner]
  }
}

resource "databricks_group" "sudoers" {
  display_name = lower("${var.metastore_name}-sudoers")
}

resource "databricks_group_member" "sudoer" {
  group_id  = databricks_group.sudoers.id
  member_id = data.databricks_user.sudoer.id
}

data "databricks_user" "sudoer" {
  user_name = "hewagallage.gunaratne@databricks.com"
}
