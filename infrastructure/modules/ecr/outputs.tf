output "repository_uris" {
  value = { for repository in aws_ecr_repository.this : repository.name => repository.repository_url }
}
