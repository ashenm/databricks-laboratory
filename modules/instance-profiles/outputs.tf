output "instance_profiles" {
  value = { for key, value in var.instance_profiles : key => {
    id        = databricks_instance_profile.instance_profiles[key].id
    name      = aws_iam_instance_profile.instance_profiles[key].name
    arn       = aws_iam_instance_profile.instance_profiles[key].arn
    role_name = aws_iam_role.instance_profiles[key].name
    role_arn  = aws_iam_role.instance_profiles[key].arn
  } }
}
