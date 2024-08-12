terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/efs/aws?version=1.6.3"
}

include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    public_subnets = ["subnet-1", "subnet-2"]
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
  env_vars    = yamldecode(file(find_in_parent_folders("env-vars.yml")))
  env        = local.env_vars.env
  region = local.global_vars.region
  project_name = local.global_vars.project_name
}

inputs = {
  name = "${local.project_name}-efs-${local.env}"
  lifecycle_policy = {
    transition_to_ia = "AFTER_7_DAYS"
  }

  security_group_name =  "${local.project_name}-sg-${local.env}"
  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
#   security_group_vpc_id = dependency.network.outputs.default_vpc_id
}
