locals {
  # Parse the file path we're in to read the env name
  parsed = regex(".*/environments/(?P<env>.*?)/.*", get_terragrunt_dir())
  env    = local.parsed.env
}