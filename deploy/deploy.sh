#!/bin/bash
# Casas de Playa - Deployment Script
# Run this on your Ubuntu droplet
# Usage: bash deploy.sh

set -e

SITE_DIR="/var/www/casasdeplaya"
HUGO_VERSION="0.155.3"

echo "=== Casas de Playa Deployment ==="

# Install Hugo if not present
if ! command -v hugo &> /dev/null; then
    echo "Installing Hugo Extended..."
    wget -q "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
    sudo dpkg -i "hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
    rm "hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
    echo "Hugo installed: $(hugo version)"
fi

# Create site directory
sudo mkdir -p "$SITE_DIR"
sudo chown -R $USER:$USER "$SITE_DIR"

# Copy project files (assumes you've uploaded them to ~/casasdeplaya)
echo "Building site..."
cd ~/casasdeplaya
hugo --minify

# Copy built files
echo "Deploying to $SITE_DIR..."
sudo rsync -av --delete public/ "$SITE_DIR/public/"

# Set up nginx
echo "Configuring nginx..."
sudo cp deploy/nginx.conf /etc/nginx/sites-available/casasdeplaya
sudo ln -sf /etc/nginx/sites-available/casasdeplaya /etc/nginx/sites-enabled/casasdeplaya
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload nginx
sudo nginx -t
sudo systemctl reload nginx

echo ""
echo "=== Deployment Complete ==="
echo "Site is live at http://$(curl -s ifconfig.me)"
echo ""
echo "Next steps:"
echo "  1. Point your domain DNS to this server's IP"
echo "  2. Install SSL: sudo apt install certbot python3-certbot-nginx"
echo "  3. Run: sudo certbot --nginx -d casasdeplaya.com -d www.casasdeplaya.com"
