terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/ecr/aws?version=2.2.1"
}

include {
  path = find_in_parent_folders()
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
  env_vars    = yamldecode(file(find_in_parent_folders("env-vars.yml")))
  env        = local.env_vars.env
  region = local.global_vars.region
  project_name = local.global_vars.project_name
}

inputs={

  repository_name = "${local.project_name}-ecr-immich-ml-${local.env}"
  repository_type = "private"

  # TODO: create the terraform service arn
  repository_read_write_access_arns = ["*"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

}