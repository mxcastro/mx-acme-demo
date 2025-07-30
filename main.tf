# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # You can change this to your desired AWS region
}

# Call the S3 bucket module
module "acme_s3_bucket" {
  source = "./modules/acme_s3_bucket"

  # Use variables defined in the root variables.tf for module inputs
  bucket_name = "${var.prefix}-${var.project}-${var.environment}"
  common_tags = {
    Environment = var.environment
    Project     = var.project
    #Purpose     = "Documents"
  }
}

module "s3-policy_set" {
   source = "./policies/s3/s3-block-public-access-bucket-level.sentinel"
   name                             = "s3-policys-set"
   tfe_organization                 = "mx-acme-demo"
   policy_set_workspace_names       = ["mx-acme-demo-dev"]
}
