terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/ecs/aws?version=5.11.0"
}

include {
  path = find_in_parent_folders()
}

dependency "s3_immich" {
  config_path = "../s3_immich"
  mock_outputs = {
    s3_bucket_id = ""
    s3_bucket_arn = ""
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    public_subnets = ["subnet-1", "subnet-2"]
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecr_immich_app" {
  config_path = "../ecr_immich_app"
  mock_outputs = {
    repository_url = ""
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecr_immich_ml" {
  config_path = "../ecr_immich_ml"
  mock_outputs = {
    repository_url = ""
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecr_redis" {
  config_path = "../ecr_redis"
  mock_outputs = {
    repository_url = ""
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecr_postgres" {
  config_path = "../ecr_postgres"
  mock_outputs = {
    repository_url = ""
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
  cluster_name = "${local.project_name}-ecs-${local.env}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    immich = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {

        redis = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "docker.io/redis:6.2-alpine@sha256:e3b17ba9479deec4b7d1eeec1548a253acc5374d68d3b27937fcfe4df8d18c7e"
          memory_reservation = 50
          readonly_root_filesystem = false

        }

        postgres = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0"
          
          # TODO: fix up the port mappings for all of the containers, this should probably follow the docker compose.
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          dependencies = [{
            containerName = "redis"
            condition     = "START"
          }]

          memory_reservation = 100
        }

        immich_ml = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = dependency.ecr_immich_ml.outputs.repository_url
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          dependencies = [{
            containerName = "postgres"
            condition     = "START"
          }]

          memory_reservation = 100
        }

        immich_app = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = dependency.ecr_immich_app.outputs.repository_url
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          dependencies = [{
            containerName = "postgres"
            condition     = "START"
          }]

          memory_reservation = 100
        }


      }

      # load_balancer = {
      #   service = {
      #     target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
      #     container_name   = "ecs-sample"
      #     container_port   = 80
      #   }
      # }

      subnet_ids = dependency.network.outputs.public_subnets

      # security_group_rules = {
      #   alb_ingress_3000 = {
      #     type                     = "ingress"
      #     from_port                = 80
      #     to_port                  = 80
      #     protocol                 = "tcp"
      #     description              = "Service port"
      #     source_security_group_id = "sg-12345678"
      #   }
      #   egress_all = {
      #     type        = "egress"
      #     from_port   = 0
      #     to_port     = 0
      #     protocol    = "-1"
      #     cidr_blocks = ["0.0.0.0/0"]
      #   }
      # }
    }
  }

}
