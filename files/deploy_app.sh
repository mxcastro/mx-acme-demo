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
GITHUB_REPO="${github_repo_url}" # <<< This variable is passed from Terraform

# Create the web application directory if it doesn't exist
echo "Creating web application directory: ${WEBAPP_DIR}"
sudo mkdir -p "${WEBAPP_DIR}"

# Clone the GitHub repository
echo "Cloning web application from ${GITHUB_REPO} into ${WEBAPP_DIR}..."
sudo git clone "${GITHUB_REPO}" "${WEBAPP_DIR}" || { echo "Failed to clone repository. Exiting."; exit 1; }

# Navigate into the web application directory
cd "${WEBAPP_DIR}" || { echo "Failed to change directory to ${WEBAPP_DIR}. Exiting."; exit 1; }

# Start Python's simple HTTP server on port 8000 in the background
# nohup ensures the process continues even if the SSH session disconnects
# & runs the command in the background
echo "Starting Python HTTP server on port 8000..."
nohup python3 -m http.server 8000 > /dev/null 2>&1 &

echo "Web application deployment script finished."
echo "You should be able to access the web app at http://<YOUR_EC2_PUBLIC_IP>:8000"
echo "Remember to open port 8000 in your EC2 instance's security group."