provider "aws" {
  region = var.aws_region
}

provider "databricks" {
  host = var.databricks_workspace_url
}
