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

##################################################
# ECS Service
##################################################

variable "service_name" {
  type        = string
  description = "Name of ECS Service."
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of the associated ECS Cluster."
}

variable "desired_count" {
  type        = number
  description = "Number of instances of the task definition to place and keep running."
}

##################################################
# Network Configuration
##################################################

variable "security_groups" {
  type        = list(string)
  default     = null
  description = "Security groups associated with the task or service."
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets associated with the task or service."
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP address to the ENI (Fargate launch type only)."
}

##################################################
# Load Balancer
##################################################

variable "target_group_arn" {
  type        = string
  description = "ARN of the Load Balancer target group to associate with the service."
}

variable "container_name" {
  type        = string
  description = "Name of the container to associate with the load balancer."
}

variable "container_port" {
  type        = number
  description = "Port on the container to associate with the load balancer."
}

##################################################
# ECS Task Definition
##################################################

variable "task_name" {
  type        = string
  description = "A unique name for your task definition."
}

variable "cpu" {
  type        = number
  description = "Number of cpu units used by the task."
}

variable "memory" {
  type        = number
  description = "Amount (in MiB) of memory used by the task."
}

variable "container_definitions" {
  type = list(object({
    name  = string
    image = string
    # repositoryCredentials = object({
    #   credentialsParameter = string
    # })
    cpu         = number
    memory      = number
    networkMode = string
    portMappings = list(object({
      containerPort = number
      protocol      = string
      appProtocol   = string
    }))
    logConfiguration = any
    healthCheck      = any
    environment = list(object({
      name  = string
      value = string
    }))
  }))
  description = "A list of valid container definitions provided as a single valid JSON document."
}

# ##################################################
# # Registry Secret
# ##################################################

# variable "registry_secret_arn" {
#   type        = string
#   description = "ARN of registry secret."
# }

##################################################
# ECR Image
##################################################

variable "ecr_image_arn" {
  type        = string
  description = "ARN of registry secret."
}

##################################################
# Cloudwatch Logs
##################################################

variable "log_group_arn" {
  type        = string
  description = "ARN of Cloudwatch log group."
}

##################################################
# Task Role Policies
##################################################

variable "task_role_policies" {
  type = list(object({
    name      = string,
    actions   = list(string),
    resources = list(string)
  }))
  description = "List of policies to attach to Task Role."
}
