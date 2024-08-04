resource "aws_ecs_cluster" "this" {
  name = "${var.name}-ecs-cluster-${var.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}
