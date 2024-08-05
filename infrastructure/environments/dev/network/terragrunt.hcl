terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=5.11.0"
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
  name = "${local.project_name}-vpc-${local.env}"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}
