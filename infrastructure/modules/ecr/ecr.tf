resource "aws_ecr_repository" "this" {
  for_each = { for repository in var.repositories : repository.repository_name => repository }

  name                 = each.value.repository_name
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = each.value.repository_name
    Env  = each.value.env
  }

  lifecycle {
    prevent_destroy = true
  }
}