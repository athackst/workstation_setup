#!/bin/bash
set -e

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders

# configure code with exensions
code --install-extensions \ 
    aeschli.vscode-css-formatter \
    DavidAnson.vscode-markdownlint \
    ginfuru.ginfuru-vscode-jekyll-syntax \
    ginfuru.vscode-jekyll-snippets \
    mitaki28.vscode-clang \
    ms-python.python \
    ms-vscode.cpptools \
    PeterJausovec.vscode-docker \
    Zignd.html-css-class-completion \
    DotJoshJohnson.xml \
    marlon407.code-groovy \
    redhat.vscode-yaml \
    secanis.jenkinsfile-support \
    smilerobotics.urdf \
    twxs.cmake \
    vector-of-bool.cmake-tools \
    yzhang.markdown-all-in-one

# install user preferences
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cp $DIR/../config/vscode.settings.json $HOME/.config/Code/User/settings.json
