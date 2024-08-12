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

dependency "efs" {
  config_path = "../efs"
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


  # create_task_exec_iam_role = true
  cloudwatch_log_group_name = "${local.project_name}-ecs-log-group-${local.env}"
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/immich"
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

      enable_execute_command = true
      assign_public_ip = true

      # Container definition(s)
      container_definitions = {

        redis = {
          cpu       = 256
          memory    = 512
          essential = true
          image     = "public.ecr.aws/docker/library/redis:alpine"
          readonly_root_filesystem = false

          health_check = {
            command     = ["CMD-SHELL", "redis-cli ping || exit 1"]
            interval    = 5
            timeout     = 5
            retries     = 3
            startPeriod = 10
          }

          mountPoints = [
            {
              sourceVolume  = "efs-storage-redis"
              containerPath = "/data"
            }
          ]
        }

        postgres = {
          cpu       = 256
          memory    = 512
          essential = true
          image     = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0"
          
          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          dependencies = [{
            containerName = "redis"
            condition     = "HEALTHY"
          }]

          environment = [
            { 
              name = "DB_DATA_LOCATION",
              value = "${dependency.s3_immich.outputs.s3_bucket_id}"
            },
            {
              name = "POSTGRES_USER",
              value = "${local.global_vars.DB_USERNAME}"
            },
            {
              name = "POSTGRES_DB",
              value = "${local.global_vars.DB_DATABASE_NAME}"
            },
            {
              name = "POSTGRES_PASSWORD",
              value = "${local.global_vars.DB_PASSWORD}"
            },
            {
              name = "PGUSER",
              value = "${local.global_vars.DB_USERNAME}"
            },
            {
              name = "POSTGRES_INITDB_ARGS",
              value = "--data-checksums"
            }
          ]

          mountPoints = [
            {
              sourceVolume  = "efs-storage-postgres"
              containerPath = "/var/lib/postgresql/data"
            }
          ]

          health_check = {
            command     = [
                            "CMD-SHELL", 
                            "pg_isready --dbname='${local.global_vars.DB_DATABASE_NAME}' --username='${local.global_vars.DB_USERNAME}'"
                          ]
            interval    = 5
            timeout     = 5
            retries     = 3
            startPeriod = 10
          }
        }

        # immich_ml = {
        #   cpu       = 256
        #   memory    = 512
        #   essential = true
        #   image     = dependency.ecr_immich_ml.outputs.repository_url

        #   # Example image used requires access to write to root filesystem
        #   readonly_root_filesystem = false

        #   dependencies = [
        #     {
        #       containerName = "postgres"
        #       condition     = "START"
        #     },
        #     {
        #       containerName = "redis"
        #       condition     = "START"
        #     }
        #   ]

        #   memory_reservation = 100
        # }

        # immich_app = {
        #   cpu       = 256
        #   memory    = 512
        #   essential = true
        #   image     = dependency.ecr_immich_app.outputs.repository_url
        #   # port_mappings = [
        #   #   {
        #   #     name          = "ecs-sample"
        #   #     containerPort = 3001
        #   #     hostPort      = 2283
        #   #     protocol      = "tcp"
        #   #   }
        #   # ]
        #   environment = [{
        #     name = "UPLOAD_LOCATION",
        #     value = "${dependency.s3_immich.outputs.s3_bucket_id}"
        #   }]
        #   # Example image used requires access to write to root filesystem
        #   readonly_root_filesystem = false

        #   dependencies = [
        #     {
        #       containerName = "postgres"
        #       condition     = "START"
        #     },
        #     {
        #       containerName = "redis"
        #       condition     = "START"
        #     }
        #   ]
        #   memory_reservation = 100
        # }


      }

      # load_balancer = {
      #   service = {
      #     target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
      #     container_name   = "ecs-sample"
      #     container_port   = 80
      #   }
      # }

      subnet_ids = dependency.network.outputs.public_subnets
      security_group_rules = {
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }

      volumes = [
        {
          name = "efs-storage-redis"
          efs_volume_configuration = {
            file_system_id = "${dependency.efs.outputs.id}"
            root_directory = "/redis"
          }
        },
        {
          name = "efs-storage-postgres"
          efs_volume_configuration = {
            file_system_id = "${dependency.efs.outputs.id}"
            root_directory = "/postgres"
          }
        }
      ]
    }
  }

}
