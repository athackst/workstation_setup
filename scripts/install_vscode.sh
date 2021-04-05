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
        # remote tools
        code --install-extension ms-vscode-remote.vscode-remote-extensionpack
        # docker
        code --install-extension ms-azuretools.vscode-docker
        # python
        code --install-extension ms-python.python
        # c++
        code --install-extension ms-vscode.cpptools
        # xml
        code --install-extension DotJoshJohnson.xml
        # yaml
        code --install-extension redhat.vscode-yaml
        # markdown (for README.md)
        code --install-extension yzhang.markdown-all-in-one
        # coding
        # compiler (bazel)
        code --install-extension BazelBuild.vscode-bazel
        # compiler (cmake)
        code --install-extension twxs.cmake
        code --install-extension ms-vscode.cmake-tools
        # proto3
        code --install-extension zxh404.vscode-proto3
        # go
        code --install-extension ms-vscode.go
        # css
        code --install-extension ecmel.vscode-html-css
        # jekyll
        code --install-extension ginfuru.ginfuru-vscode-jekyll-syntax
        code --install-extension ginfuru.vscode-jekyll-snippets
        # ros
        code --install-extension ms-iot.vscode-ros
        code --install-extension smilerobotics.urdf
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
