#!/bin/bash

# Auto-Commit Service Installer
echo "=== Git Auto-Commit Service Installer ==="

# Enable Tab Completion for Directory Selection
read -e -p "Enter the absolute path to the Git repository: " REPO_PATH
REPO_PATH=$(realpath "$REPO_PATH") # Ensure it's an absolute path

# Validate repository
if [ ! -d "${REPO_PATH}/.git" ]; then
    echo "Error: The specified folder is not a Git repository."
    exit 1
fi

# Get the current user
USER=$(whoami)

# Ensure dependencies are installed
echo "Installing dependencies..."
sudo apt-get update
sudo apt install inotify-tools git -y 

# Define paths
DIR="$(dirname "$(readlink -f "$0" 2>/dev/null || realpath "$0")")"
SCRIPT_PATH="/usr/local/bin/auto_commit.sh"
SERVICE_TRACKER="/var/lib/auto_commit_services.list"

# Ensure tracking file exists
sudo touch "$SERVICE_TRACKER"

# Create a symbolic link to the script
sudo ln -sf "${DIR}/auto_commit.sh" "${SCRIPT_PATH}"

# Extract repo name for service name
REPO_NAME=$(basename "$REPO_PATH")
SERVICE_NAME="auto_commit_${REPO_NAME}.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

# Check if auto_commit.sh exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: auto_commit.sh not found. Ensure it is in the same directory as this script."
    exit 1
fi

# Create systemd service file
echo "Creating systemd service for $REPO_NAME..."

sudo tee "$SERVICE_PATH" > /dev/null <<EOL
[Unit]
Description=Git Auto-Commit Service for $REPO_NAME
After=network.target

[Service]
ExecStart=$SCRIPT_PATH $REPO_PATH
Restart=always
User=$USER
WorkingDirectory=$REPO_PATH
StandardOutput=append:/var/log/auto_commit_$REPO_NAME.log
StandardError=append:/var/log/auto_commit_$REPO_NAME.log

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable, and start the service
echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting the service: $SERVICE_NAME"
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

# Log the service installation
echo "$SERVICE_NAME $REPO_PATH" | sudo tee -a "$SERVICE_TRACKER" > /dev/null

# Confirm status
echo "Service '$SERVICE_NAME' is now running!"
echo "Check status with: sudo systemctl status $SERVICE_NAME"
