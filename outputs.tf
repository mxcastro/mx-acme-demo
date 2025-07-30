# Output the ID of the created S3 bucket
output "s3_bucket_id" {
  description = "The ID (name) of the S3 bucket."
  value       = module.acme_s3_bucket.bucket_id
}

# Output the ARN of the created S3 bucket
output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = module.acme_s3_bucket.bucket_arn
}
