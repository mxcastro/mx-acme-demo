ACME Corp Web App Deployment with Terraform
This repository contains a simple single-page web application for ACME Corp, designed to be deployed on an AWS EC2 instance using Terraform. It serves as a practical demonstration of Infrastructure as Code (IaC) principles.

Project Structure
index.html: The core single-page web application for ACME Corp Widgets.

user_data.sh: A shell script used as EC2 User Data to automate the setup of the web server and deployment of the web app.

main.tf (Example - not included in this repository, but you'll create it): Your Terraform configuration file to provision AWS resources.

Web Application (index.html)
The index.html file is a self-contained web application built with HTML, Tailwind CSS (via CDN), and vanilla JavaScript. It simulates a customer-facing website for ordering widgets, featuring:

Product display.

Shopping cart functionality.

Simplified order placement.

Display of session-based "past" orders.

This design ensures minimal dependencies, making it ideal for straightforward deployment.

EC2 User Data Script (user_data.sh)
The user_data.sh script automates the following steps on your EC2 instance upon launch:

System Update: Updates the package lists (apt-get update).

Install Dependencies: Installs nginx (a high-performance web server) and git.

Clone Repository: Clones this GitHub repository into /var/www/acme-corp-webapp.

Nginx Configuration:

Removes the default Nginx site configuration.

Creates a new Nginx server block configuration to serve the index.html file from the cloned repository's directory (/var/www/acme-corp-webapp).

Enables the new configuration by creating a symlink.

Start Nginx: Starts and enables the Nginx service to run on boot.

Important Note for user_data.sh:
Before using the user_data.sh script, you MUST replace YOUR_GITHUB_REPO_URL with the actual HTTPS URL of your GitHub repository where index.html resides.

GITHUB_REPO_URL="https://github.com/your-username/your-repo-name.git" # <--- REPLACE THIS


Ensure your repository is publicly accessible, or configure appropriate SSH keys/access tokens if it's private (which requires additional setup not covered in this basic script).

Terraform Deployment (Example main.tf Snippet)
Below is an example of how you would integrate the user_data.sh script into your main.tf Terraform configuration.

# main.tf (Example)

provider "aws" {
  region = "us-east-1" # Choose your desired AWS region
}

resource "aws_security_group" "web_sg" {
  name        = "acme-corp-web-sg"
  description = "Allow HTTP inbound traffic for ACME Corp web app"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For demo purposes, allows access from anywhere. Restrict in production.
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_ADDRESS/32"] # Replace with your public IP for SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "acme_web_server" {
  ami           = "ami-0abcdef1234567890" # Replace with a valid Ubuntu 22.04 LTS AMI ID for your region (e.g., ami-053b0d53c27927904 for us-east-1)
  instance_type = "t2.micro"
  key_name      = "your-ec2-key-pair"     # Replace with the name of your EC2 key pair for SSH
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Read the user_data script from a file
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "ACME-Corp-WebApp-Server"
  }
}

output "web_app_url" {
  description = "The public IP address of the EC2 instance hosting the web app."
  value       = "http://${aws_instance.acme_web_server.public_ip}"
}


Terraform Setup Steps:
Create main.tf: Create a file named main.tf in your Terraform project directory and paste the example configuration above into it.

Update Placeholders:

Replace ami-0abcdef1234567890 with a suitable AMI ID for your chosen region (e.g., an Ubuntu 22.04 LTS AMI).

Replace your-ec2-key-pair with the name of an existing EC2 key pair in your AWS account.

Replace YOUR_IP_ADDRESS/32 in the security group with your actual public IP address (or 0.0.0.0/0 for broader access, but be cautious in production).

Place user_data.sh: Ensure the user_data.sh script (with the correct GITHUB_REPO_URL) is in the same directory as your main.tf file.

Initialize Terraform:

terraform init


Plan Deployment:

terraform plan


Apply Deployment:

terraform apply


Confirm with yes when prompted.

Access the Web App: After Terraform successfully applies, it will output the web_app_url. Copy this URL and paste it into your web browser to access the ACME Corp Widgets website.

Cleanup
To destroy the AWS resources created by Terraform (and avoid incurring charges), run:

terraform destroy


Confirm with yes when prompted.