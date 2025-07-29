terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner       = var.owner
      Project     = var.project
      Environment = var.environment
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc-${var.environment}"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


resource "aws_security_group" "order_web" {
  description = "Order Web Security Group Access"
  name        = "${var.prefix}-security-group"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_eip" "order_web" {
  instance = aws_instance.order_web.id
  //vpc      = true
  tags = {
    "Name" = "${var.prefix}-${var.project}-${var.environment}"
  }
}

resource "aws_eip_association" "order_web" {
  instance_id   = aws_instance.order_web.id
  allocation_id = aws_eip.order_web.id
}

resource "aws_instance" "order_web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [aws_security_group.order_web.id]

  user_data = <<-EOF
    #!/bin/bash
    # This script is designed to be used as EC2 User Data to set up a web server
    # and deploy a single-page web application from a GitHub repository.

    # --- Configuration Variables ---
    # IMPORTANT: Replace this with the actual URL of your GitHub repository.
    # Ensure the repository is publicly accessible or configure SSH keys/access tokens
    # if it's private (which is beyond the scope of this basic script).
    GITHUB_REPO_URL="https://github.com/your-username/your-repo-name.git" # <--- REPLACE THIS
    APP_DIR="/var/www/acme-corp-webapp" # Directory where the app will be cloned
    NGINX_CONF_PATH="/etc/nginx/sites-available/default"
    NGINX_SYMLINK_PATH="/etc/nginx/sites-enabled/default"

    # --- 1. Update System Packages ---
    echo "Updating system packages..."
    sudo apt-get update -y
    echo "System packages updated."

    # --- 2. Install Nginx and Git ---
    echo "Installing Nginx and Git..."
    sudo apt-get install -y nginx git
    echo "Nginx and Git installed."

    # --- 3. Clone the GitHub Repository ---
    echo "Cloning the GitHub repository: ${GITHUB_REPO_URL}..."
    # Create the directory if it doesn't exist
    sudo mkdir -p ${APP_DIR}
    # Clone the repository into the designated application directory
    # Using --depth 1 for a shallow clone to save time and space
    sudo git clone --depth 1 ${GITHUB_REPO_URL} ${APP_DIR}
    # Check if cloning was successful
    if [ $? -eq 0 ]; then
        echo "Repository cloned successfully to ${APP_DIR}."
    else
        echo "Error: Failed to clone repository. Please check GITHUB_REPO_URL and permissions."
        exit 1
    fi

    # --- 4. Configure Nginx to Serve the Web App ---
    echo "Configuring Nginx..."

    # Remove the default Nginx configuration symlink to prevent conflicts
    if [ -L "${NGINX_SYMLINK_PATH}" ]; then
        echo "Removing existing Nginx default site symlink..."
        sudo rm ${NGINX_SYMLINK_PATH}
    fi

    # Create a new Nginx configuration file
    # This configuration will serve the index.html from the cloned repository
    sudo bash -c "cat > ${NGINX_CONF_PATH}" <<EOT
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root ${APP_DIR}; # Set the root directory to your cloned app
        index index.html index.htm;

        server_name _; # Listen for any hostname

        location / {
            try_files \$uri \$uri/ =404;
        }

        # Optional: Basic error page
        error_page 404 /404.html;
        location = /404.html {
            internal;
        }
    }
    EOT

    # Create a symlink from sites-available to sites-enabled to activate the new config
    echo "Creating Nginx configuration symlink..."
    sudo ln -s ${NGINX_CONF_PATH} ${NGINX_SYMLINK_PATH}

    # --- 5. Start and Enable Nginx Service ---
    echo "Starting and enabling Nginx service..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "Nginx service started and enabled."

    echo "Web application deployment complete!"
    echo "You should now be able to access your ACME Corp Widgets website via the EC2 instance's public IP address."
  EOF

  tags = {
    Name = "${var.prefix}-${var.project}-${var.environment}-instance"
  }
}

# module "s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"
#   bucket_prefix = "${var.prefix}-s3-${var.environment}"
#   acl    = "private"
#   versioning = {
#     enabled = true
#   }
# }
