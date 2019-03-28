#!/bin/bash
set -e

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders

# configure code with exensions
code --install-extension aeschli.vscode-css-formatter
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension ginfuru.ginfuru-vscode-jekyll-syntax 
code --install-extension ginfuru.vscode-jekyll-snippets
code --install-extension mitaki28.vscode-clang
code --install-extension ms-python.python
code --install-extension ms-vscode.cpptools
code --install-extension PeterJausovec.vscode-docker
code --install-extension Zignd.html-css-class-completion
code --install-extension DotJoshJohnson.xml
code --install-extension marlon407.code-groovy
code --install-extension redhat.vscode-yaml
code --install-extension secanis.jenkinsfile-support
code --install-extension smilerobotics.urdf
code --install-extension twxs.cmake
code --install-extension vector-of-bool.cmake-tools
code --install-extension yzhang.markdown-all-in-one

# install user preferences
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cp $DIR/../config/vscode.settings.json $HOME/.config/Code/User/settings.json
