# terraform {
#   source  = "../../../modules//fargate"
# }

# include {
#   path = find_in_parent_folders()
# }

# dependency "s3_immich" {
#   config_path = "../s3_immich"
#   mock_outputs = {
#     s3_bucket_arn = ""
#     s3_bucket_id = ""
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

# locals {
#   global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
#   env_vars    = yamldecode(file(find_in_parent_folders("env-vars.yml")))
#   env        = local.env_vars.env
#   project_name = local.global_vars.project_name
# }

# inputs = {
#   name        = "${local.project_name}"
#   env         = "${local.env}"
# }