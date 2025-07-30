# The desired name for the S3 bucket
variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

# Tags to apply to all resources
variable "common_tags" {
  description = "A map of common tags to apply to all resources."
  type        = map(string)
   default = {
    ManagedBy = "ACME"
    Owner     = "HCP Terraform Expert Team"
  }
}
