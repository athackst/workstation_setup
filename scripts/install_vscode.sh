#!/bin/bash
set -e

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  code # or code-insiders

# set up gitconfig
read -p "Install vscode extensions? (y/N): " yn
case $yn in
    [Yy]* )
        # configure code with exensions
        # docker
        code --install-extension ms-azuretools.vscode-docker
        # github pull requests
        code --install-extension github.vscode-pull-request-github
        # gitlens
        code --install-extension eamodio.gitlens
        # jupyter
        code --install-extension ms-toolsai.jupyter
        # markdown (for README.md)
        code --install-extension yzhang.markdown-all-in-one
        code --install-extension davidanson.vscode-markdownlint
        # remote tools
        code --install-extension ms-vscode-remote.vscode-remote-extensionpack
        # yaml
        code --install-extension redhat.vscode-yaml
    ;;
    [Nn]* ) ;;
    * )     ;;
esac

# install user preferences
read -p "Update user preferences? (y/N): " yn
case $yn in
    [Yy]* )
        DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
        cp -r $DIR/../user/.config/Code/ $HOME/.config/Code/
    ;;
    [Nn]* ) ;;
    * )     ;;
esac
