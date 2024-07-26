#/bin/sh
set -e

# Install tiling shell gnome extension
sudo apt-get install -y gnome-shell-extension-manager
pip install -U gnome-extensions-cli

gext install tilingshell@ferrarodomenico.com
gext enable tilingshell@ferrarodomenico.com
