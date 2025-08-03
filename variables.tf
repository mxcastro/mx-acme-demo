# Project name to be used in bucket naming and tags
variable "project" {
  description = "The name of the project. Used for naming and tagging."
  type        = string
  default     = "acme-demo" # Example default
}

# Environment (e.g., dev, staging, prod)
variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev" # Example default
}

# Required prefix for the instance name
variable "prefix" {
  description = "A required prefix to append to the instance name."
  type        = string
  default     = "web" # Example default
}