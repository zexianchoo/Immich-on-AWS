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
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecr_immich_app" {
  config_path = "../ecr_immich_app"
  mock_outputs = {
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecr_immich_ml" {
  config_path = "../ecr_immich_ml"
  mock_outputs = {
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecr_redis" {
  config_path = "../ecr_redis"
  mock_outputs = {
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecr_postgres" {
  config_path = "../ecr_postgres"
  mock_outputs = {
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
          image     = 
          memory_reservation = 50
        }

        postgres = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = ""
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
            containerName = "fluent-bit"
            condition     = "START"
          }]

          enable_cloudwatch_logging = false
          log_configuration = {
            logDriver = "awsfirelens"
            options = {
              Name                    = "firehose"
              region                  = "eu-west-1"
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = "example"
        service = {
          client_alias = {
            port     = 80
            dns_name = "ecs-sample"
          }
          port_name      = "ecs-sample"
          discovery_name = "ecs-sample"
        }
      }

      load_balancer = {
        service = {
          target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
          container_name   = "ecs-sample"
          container_port   = 80
        }
      }

      subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = "sg-12345678"
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }

}
