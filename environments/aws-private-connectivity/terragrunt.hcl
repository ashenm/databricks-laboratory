include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "environments" {
  path = find_in_parent_folders("environments.hcl")
}

inputs = {
  project = "voyager"
}
