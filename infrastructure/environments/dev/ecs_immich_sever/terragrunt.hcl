# terraform {
#   source  = "../../../modules//ecs_service"
# }

# include {
#   path = find_in_parent_folders()
# }

# dependency "ecs_cluster" {
#   config_path = "../ecs_cluster"
#   mock_outputs = {
#     ecs_cluster_arn = ""
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

# dependency "security_group_ecs" {
#   config_path = "../security_group_ecs"
#   mock_outputs = {
#     security_group_id = ""
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

# dependency "s3_immich" {
#   config_path = "../s3_immich"
#   mock_outputs = {
#     s3_bucket_id = ""
#     s3_bucket_arn = ""
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

# locals {
#   global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
#   env_vars    = yamldecode(file(find_in_parent_folders("env-vars.yml")))
#   env        = local.env_vars.env
#   region = local.global_vars.region
#   project_name = local.global_vars.project_name
# }

# inputs = {
#   name = "${local.project_name}"
#   env  = "${local.env}"
#   service_name        = "immich-server"
#   ecs_cluster_arn     = dependency.ecs_cluster.outputs.ecs_cluster_arn
#   desired_count       = 1
#   subnet_ids          = [for subnet in dependency.network.outputs.private_subnets : subnet.id]
#   assign_public_ip    = true
#   container_name      = "immich-server"
#   container_port      = local.env_vars.api_port
#   task_name           = "immich-server"
#   cpu                 = 512
#   memory              = 1024
#   ecr_image_arn       = "arn:aws:ecr:${local.region}:${local.account_id}:repository/backend-fastapi-api-service:${get_env("CI_COMMIT_SHA")}"
# #   log_group_arn       = dependency.cloudwatch_log_group_backend_api.outputs.log_group_arn
#   container_definitions = [
#     {
#       name  = "immich-server"
#       image = 
#       cpu         = 512
#       memory      = 1024
#       portMappings = [
#         {
#           containerPort = local.env_vars.api_port
#           protocol      = "tcp"
#           appProtocol   = "http"
#         }
#       ]
#       environment = [
#         {
#           name = "UPLOAD_LOCATION"
#           # TODO: check the proper s3:// filepath, but i believe this should be okay.
#           value = "${dependency.s3_immich.outputs.s3_bucket_id}"
#         }
#       ]
#     }
#   ]
#   task_role_policies = []
# }
