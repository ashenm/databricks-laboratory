resource "aws_vpc_endpoint_service" "main" {
  network_load_balancer_arns = [aws_lb.main.arn]
  acceptance_required        = false
  tags                       = { Name = upper(var.name_prefix) }
}

resource "aws_vpc_endpoint_service_allowed_principal" "databricks" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.main.id
  principal_arn           = "arn:aws:iam::565502421330:role/private-connectivity-role-${data.aws_region.current.region}"
}
