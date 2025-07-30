# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # You can change this to your desired AWS region
}

# Call the S3 bucket module
module "acme_s3_bucket" {
  source = "../modules/acme_s3_bucket"

  # Use variables defined in the root variables.tf for module inputs
  bucket_name = "${var.prefix}-${var.project}-${var.environment}"
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}
