include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  aws_region = get_env("AWS_REGION", "ap-southeast-1")
}