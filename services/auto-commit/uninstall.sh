#!/bin/bash

# Auto-Commit Service Uninstaller
echo "=== Git Auto-Commit Service Uninstaller ==="

# Define tracking file
SERVICE_TRACKER="/var/lib/auto_commit_services.list"

# Check if the tracking file exists
if [ ! -f "$SERVICE_TRACKER" ] || [ ! -s "$SERVICE_TRACKER" ]; then
    echo "No auto-commit services found."
    exit 1
fi

# Display installed services
echo "Installed auto-commit services:"
cat -n "$SERVICE_TRACKER"
echo ""

# Prompt for which service to uninstall
read -rp "Enter the number of the service you want to uninstall (or 'all' to remove all): " SELECTION

if [ "$SELECTION" == "all" ]; then
    while read -r LINE; do
        SERVICE_NAME=$(echo "$LINE" | awk '{print $1}')
        REPO_PATH=$(echo "$LINE" | awk '{$1=""; print $0}' | xargs)

        echo "Removing $SERVICE_NAME ($REPO_PATH)..."
        sudo systemctl stop "$SERVICE_NAME"
        sudo systemctl disable "$SERVICE_NAME"
        sudo rm "/etc/systemd/system/$SERVICE_NAME"
        sudo rm -f "/var/log/auto_commit_${SERVICE_NAME#auto_commit_}.log"
    done < "$SERVICE_TRACKER"

    sudo rm "$SERVICE_TRACKER"
    echo "All services removed."
    sudo systemctl daemon-reload
    exit 0
fi

# Get the selected service
SELECTED_SERVICE=$(sed -n "${SELECTION}p" "$SERVICE_TRACKER")

if [ -z "$SELECTED_SERVICE" ]; then
    echo "Invalid selection."
    exit 1
fi

# Extract service name and repo path
SERVICE_NAME=$(echo "$SELECTED_SERVICE" | awk '{print $1}')
REPO_PATH=$(echo "$SELECTED_SERVICE" | awk '{$1=""; print $0}' | xargs)

# Confirm before removing
read -rp "Are you sure you want to remove $SERVICE_NAME? (y/n) " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Uninstallation cancelled."
    exit 1
fi

# Remove the service
echo "Stopping and disabling $SERVICE_NAME..."
sudo systemctl stop "$SERVICE_NAME"
sudo systemctl disable "$SERVICE_NAME"
sudo rm "/etc/systemd/system/$SERVICE_NAME"

# Remove log file if it exists
LOG_PATH="/var/log/${SERVICE_NAME%.service}.log"
if [ -f "$LOG_PATH" ]; then
    echo "Removing log file: $LOG_PATH"
    sudo rm "$LOG_PATH"
fi

# Remove the service from the tracking file
sudo sed -i "/^$SERVICE_NAME /d" "$SERVICE_TRACKER"

# Remove the script symlink if no other services remain
if [ ! -s "$SERVICE_TRACKER" ]; then
    SCRIPT_PATH="/usr/local/bin/auto_commit.sh"
    if [ -L "$SCRIPT_PATH" ]; then
        echo "Removing script link: $SCRIPT_PATH"
        sudo rm "$SCRIPT_PATH"
    fi
    sudo rm "$SERVICE_TRACKER"
fi

# Reload systemd
echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Service '$SERVICE_NAME' has been uninstalled!"
