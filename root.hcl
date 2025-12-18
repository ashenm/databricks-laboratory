generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("${get_repo_root()}/templates/versions.tftpl")
}
