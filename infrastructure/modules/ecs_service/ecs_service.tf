resource "aws_ecs_service" "this" {
  name            = "${var.name}-${var.service_name}-ecs-service-${var.env}"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.this.family
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  depends_on = [aws_ecs_task_definition.this]
}
