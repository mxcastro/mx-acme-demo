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

variable "github_repo_url" {
  description = "The URL of the GitHub repository containing the web app (e.g., 'https://github.com/your-username/your-repo.git')."
  type        = string
  # IMPORTANT: Replace this with your actual GitHub repository URL where index.html is located.
  default     = "https://github.com/your-username/acme-widgets.git"
}