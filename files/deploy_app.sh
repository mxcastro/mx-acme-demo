#!/bin/bash
# This script is designed to be used as EC2 User Data to set up a web server
# and deploy a single-page web application from a GitHub repository.

# --- Configuration Variables ---
# IMPORTANT: Replace this with the actual URL of your GitHub repository.
# Ensure the repository is publicly accessible or configure SSH keys/access tokens
# if it's private (which is beyond the scope of this basic script).
GITHUB_REPO_URL="https://github.com/mxcastro/order-webapp.git"
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
echo "Cloning the GitHub repository: \${GITHUB_REPO_URL}..."
# Create the directory if it doesn't exist
sudo mkdir -p \${APP_DIR}
# Clone the repository into the designated application directory
# Using --depth 1 for a shallow clone to save time and space
sudo git clone --depth 1 \${GITHUB_REPO_URL} \${APP_DIR}
# Check if cloning was successful
if [ $? -eq 0 ]; then
    echo "Repository cloned successfully to \${APP_DIR}."
else
    echo "Error: Failed to clone repository. Please check GITHUB_REPO_URL and permissions."
    exit 1
fi

# --- 4. Configure Nginx to Serve the Web App ---
echo "Configuring Nginx..."

# Remove the default Nginx configuration symlink to prevent conflicts
if [ -L "\${NGINX_SYMLINK_PATH}" ]; then
    echo "Removing existing Nginx default site symlink..."
    sudo rm \${NGINX_SYMLINK_PATH}
fi

# Create a new Nginx configuration file
# This configuration will serve the index.html from the cloned repository
sudo bash -c "cat > \${NGINX_CONF_PATH}" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    listen 8001; # Add 8001 port
    listen [::]:8001; # Add IPv6 8001 port
    
    root \${APP_DIR}; # Set the root directory to your cloned app
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
EOF

# Create a symlink from sites-available to sites-enabled to activate the new config
echo "Creating Nginx configuration symlink..."
sudo ln -s \${NGINX_CONF_PATH} \${NGINX_SYMLINK_PATH}

# --- 5. Start and Enable Nginx Service ---
echo "Starting and enabling Nginx service..."
sudo systemctl start nginx
sudo systemctl enable nginx
echo "Nginx service started and enabled."

echo "Web application deployment complete!"
echo "You should now be able to access your ACME Corp Widgets website via the EC2 instance's public IP address."
