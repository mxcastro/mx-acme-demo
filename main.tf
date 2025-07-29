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
  user_data = <<-EOF
              #!/bin/bash
              # This script is designed to be used as user_data for an AWS EC2 instance (Ubuntu/Debian based).

              # Update package lists
              echo "Updating package lists..."
              sudo apt-get update -y

              # Install Git (if not already installed)
              echo "Installing Git..."
              sudo apt-get install -y git

              # Define the directory for the web application
              WEBAPP_DIR="/var/www/acme-widgets"
              GITHUB_REPO="/${var.github_repo_url}" # <<< Using Terraform variable for GitHub Repo URL

              # Create the web application directory if it doesn't exist
              echo "Creating web application directory: /${WEBAPP_DIR}"
              sudo mkdir -p "/${WEBAPP_DIR}"

              # Clone the GitHub repository
              echo "Cloning web application from /${GITHUB_REPO} into /${WEBAPP_DIR}..."
              sudo git clone "/${GITHUB_REPO}" "/${WEBAPP_DIR}" || { echo "Failed to clone repository. Exiting."; exit 1; }

              # Navigate into the web application directory
              cd "/${WEBAPP_DIR}" || { echo "Failed to change directory to ${WEBAPP_DIR}. Exiting."; exit 1; }

              # Start Python's simple HTTP server on port 8000 in the background
              # nohup ensures the process continues even if the SSH session disconnects
              # & runs the command in the background
              echo "Starting Python HTTP server on port 8000..."
              nohup python3 -m http.server 8000 > /dev/null 2>&1 &

              echo "Web application deployment script finished."
              echo "You should be able to access the web app at http://<YOUR_EC2_PUBLIC_IP>:8000"
              echo "Remember to open port 8000 in your EC2 instance's security group."
              EOF

  tags = {
    Name = "acme-webapp-instance"
  }
}