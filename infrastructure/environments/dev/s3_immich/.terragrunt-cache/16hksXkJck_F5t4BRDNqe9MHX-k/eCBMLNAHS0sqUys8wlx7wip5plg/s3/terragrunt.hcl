terraform {
  source  = "../../../modules//s3"
}

include {
  path = find_in_parent_folders()
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
  env_vars    = yamldecode(file(find_in_parent_folders("env-vars.yml")))
  env        = local.env_vars.env
  project_name = local.global_vars.project_name
}

inputs = {
  name        = "${local.project_name}"
  env         = "${local.env}"
  bucket_name = "s3_immich"
}