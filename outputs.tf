# outputs.tf

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.webapp_instance.public_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance."
  value       = aws_instance.webapp_instance.public_dns
}

output "webapp_url" {
  description = "The URL to access the ACME Corp web application."
  value       = "http://${aws_instance.webapp_instance.public_ip}:8000"
}

output "ssh_private_key_file" {
  description = "Path to the generated SSH private key file. Keep this file secure."
  value       = local_file.ssh_private_key.filename
  sensitive   = true # Mark as sensitive to prevent showing content in logs
}