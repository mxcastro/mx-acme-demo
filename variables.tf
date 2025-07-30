# Project name to be used in bucket naming and tags
variable "project" {
  description = "The name of the project. Used for bucket naming and tagging."
  type        = string
  default     = "acme-demo" # Example default
}

# Environment (e.g., dev, staging, prod)
variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev" # Example default
}

# Required prefix for the bucket name to ensure uniqueness
variable "prefix" {
  description = "A required suffix to append to the bucket name for uniqueness."
  type        = string
  default     = "data" # Example default
}

# Tags to apply to all resources
variable "tags" {
  description = "A map of tags to apply to this resource."
  type        = map(string)
  default = {}
}