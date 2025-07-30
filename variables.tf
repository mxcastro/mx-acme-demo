# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # You can change this to your desired region
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro" # Free tier eligible instance type
}

variable "key_pair_name" {
  description = "The name for the EC2 key pair."
  type        = string
  default     = "acme-webapp-key"
}