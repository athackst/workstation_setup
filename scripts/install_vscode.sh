#!/bin/bash
set -e

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders

# configure code with exensions

# coding
# remote tools
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
# docker
code --install-extension ms-azuretools.vscode-docker
# python
code --install-extension ms-python.python
# c++
code --install-extension ms-vscode.cpptools
code --install-extension mitaki28.vscode-clang
# xml
code --install-extension DotJoshJohnson.xml
# yaml
code --install-extension redhat.vscode-yaml
# markdown (for README.md)
code --install-extension yzhang.markdown-all-in-one
code --instadll-extension DavidAnson.vscode-markdownlint
# compiler (bazel)
code --install-extension bazelbuild.vscode-bazel
# compiler (cmake)
code --install-extension twxs.cmake
code --install-extension vector-of-bool.cmake-tools


# install user preferences
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cp $DIR/../config/vscode.settings.json $HOME/.config/Code/User/settings.json
