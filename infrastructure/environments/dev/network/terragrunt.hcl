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
  create_elasticache_subnet_group = false
  create_redshift_subnet_group = false

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true
  create_igw = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  single_nat_gateway = true
  
  default_security_group_egress = [
    {
      cidr_blocks = "0.0.0.0/0"
      protocol    = "-1" # -1 means all protocols
      from_port   = 0    # 0 means all ports
      to_port     = 0    # 0 means all ports
      description = "Allow all outbound traffic"
    }
  ]
  default_security_group_ingress = [
    {
      cidr_blocks = "0.0.0.0/0"
      protocol    = "-1" # -1 means all protocols
      from_port   = 0    # 0 means all ports
      to_port     = 0    # 0 means all ports
      description = "Allow all inbound traffic"
    }
  ]
  default_security_group_name = "${local.project_name}-vpc-sg-${local.env}"

}
