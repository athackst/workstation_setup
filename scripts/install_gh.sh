#!/bin/bash

echo "Downloading latest gh cli..."

curl -s https://api.github.com/repos/cli/cli/releases/latest \
| grep "browser_download_url.*linux_amd64.deb" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

sudo apt install -y ./gh_*_linux_amd64.deb
rm ./gh_*_linux_amd64.deb
