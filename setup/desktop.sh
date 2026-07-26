#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Install tiling shell gnome extension
sudo apt-get install -y gnome-shell-extension-manager
pip install -U gnome-extensions-cli

gext install tilingshell@ferrarodomenico.com
gext enable tilingshell@ferrarodomenico.com

dconf load /org/gnome/shell/extensions/tilingshell/ \
    < "$SCRIPT_DIR/tilingshell-settings-dump.txt"
