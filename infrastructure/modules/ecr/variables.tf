variable "repositories" {
  type = list(
    object({
      repository_name = string
      env             = string
    })
  )
  description = "List of ECR repositories to be created."
}
