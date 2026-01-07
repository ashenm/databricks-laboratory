# resource "aws_vpc_endpoint_service" "ncc" {
#   acceptance_required        = false
#   network_load_balancer_arns = [aws_lb.ncc.arn]
#   private_dns_name           = "s3.${data.aws_region.current.region}.amazonaws.com"
#   tags                       = { Name = upper("${var.name_prefix}-ncc") }
# }

# resource "aws_vpc_endpoint_service_allowed_principal" "databricks" {
#   vpc_endpoint_service_id = aws_vpc_endpoint_service.ncc.id
#   principal_arn           = "arn:aws:iam::565502421330:role/private-connectivity-role-${data.aws_region.current.region}"
# }
