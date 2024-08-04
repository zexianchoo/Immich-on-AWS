terraform {
  source  = "../../../modules/ecr"
}

include {
  path = find_in_parent_folders()
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
  env_vars    = yamldecode(file(find_in_parent_folders("env-vars.yml")))
  project_name = local.global_vars.project_name
  env        = local.env_vars.env
}

inputs = {
    repository_name = "immich-app"
}