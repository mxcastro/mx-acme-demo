# main.tf

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create a new EC2 Key Pair for SSH access
# This will generate a new private key and save it locally.
# You will need to save the private_key_pem content to a .pem file
# and set its permissions to 400 (chmod 400 your-key.pem) to use it for SSH.
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.ec2_key.public_key_openssh

  # Optional: Add tags to the key pair
  tags = {
    Name = "${var.key_pair_name}-key"
  }
}

# Output the private key to a local file (for local Terraform runs)
# For HCP Terraform, you would typically manage SSH keys differently,
# e.g., by uploading a pre-existing public key.
# This local_file resource is mainly for demonstration purposes if running locally.
resource "local_file" "ssh_private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${aws_key_pair.generated_key.key_name}.pem"
  file_permission = "0400" # Set read-only permissions for the private key
}


# Create a Security Group for the EC2 instance
# This security group allows SSH (port 22) and HTTP on port 8000.
resource "aws_security_group" "webapp_sg" {
  name        = "webapp-security-group"
  description = "Allow SSH and HTTP traffic for ACME Corp web app"
  vpc_id      = data.aws_vpc.default.id # Use default VPC

  # Ingress rule for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to known IPs
    description = "Allow SSH access"
  }

  # Ingress rule for the web app on port 8000
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow access from anywhere
    description = "Allow web app access on port 8000"
  }

  # Egress rule (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "acme-webapp-sg"
  }
}

# Data source to get the default VPC ID
data "aws_vpc" "default" {
  default = true
}

# Data source to get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical's owner ID for Ubuntu AMIs
}

# Define the EC2 instance
resource "aws_instance" "webapp_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.webapp_sg.id]

  # User data script to configure the instance on launch
  # Reads the script content from a file in the 'files' directory
  # user_data = templatefile("${path.module}/deploy_app.sh", {
  #   github_repo_url = var.github_repo_url # Only pass the variable that the script expects
  # })
  user_data_base64 = base64encode(file("${path.module}/deploy_app.yml"))

  tags = {
    Name = "acme-webapp-instance"
  }
}