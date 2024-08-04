##################################################
# Module Globals
##################################################

variable "name" {
  type        = string
  description = "Name to be used as resource identifier (usually product/project name). All created infrastructure will use this name as a base for their own names."
}

variable "env" {
  type        = string
  description = "Deployment environment that the module is for (dev/stage/prod)."
}

variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket to be deployed."
}

variable "object_ownership" {
  type        = string
  default     = "BucketOwnerPreferred"
  description = "Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced"
}

variable "bucket_policies" {
  type        = list(string)
  default     = []
  description = "Additional S3 bucket policies to append"
}