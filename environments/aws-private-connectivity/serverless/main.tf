resource "databricks_mws_network_connectivity_config" "ncc" {
  name   = lower(var.name_prefix)
  region = data.aws_region.current.region
}

# resource "databricks_mws_ncc_private_endpoint_rule" "ncc" {
#   network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
#   domain_names                   = ["api.example.com"]
#   endpoint_service               = aws_vpc_endpoint_service.ncc.service_name
#   depends_on                     = [time_sleep.vpc_endpoint_service]
# }

# resource "time_sleep" "vpc_endpoint_service" {
#   depends_on      = [aws_vpc_endpoint_service.ncc, aws_vpc_endpoint_service_allowed_principal.databricks]
#   create_duration = "1m"
# }

resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  endpoint_service               = "${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.region}.s3"
  resource_names                 = [for resource in data.aws_resourcegroupstaggingapi_resources.buckets.resource_tag_mapping_list : replace(resource.resource_arn, "arn:aws:s3:::", "")]
}

resource "databricks_mws_ncc_binding" "main" {
  workspace_id                   = var.databricks_workspace_id
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
}

data "aws_vpc" "main" {
  tags = {
    Name        = upper(var.name_prefix)
    Environment = upper(var.environment)
    Project     = upper(var.project_name)
  }
}

data "aws_resourcegroupstaggingapi_resources" "buckets" {
  resource_type_filters = ["s3"]

  tag_filter {
    key    = "Project"
    values = [upper(var.project_name)]
  }

  tag_filter {
    key    = "Environment"
    values = [upper(var.environment)]
  }
}

data "aws_partition" "current" {}
data "aws_region" "current" {}
