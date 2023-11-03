#!/bin/bash
set -e

# install VS Code
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
    [Yy]*)
        # configure code with exensions
        # Preview PDF files
        code --install-extension analytic-signal.preview-pdf
        # Use meld in diffs
        code --install-extension danielroedl.meld-diff
        # Git lens for code history and management
        code --install-extension eamodio.gitlens
        # Github pull request support
        code --install-extension GitHub.vscode-pull-request-github
        # Docker
        code --install-extension ms-azuretools.vscode-docker
        # Remote containers
        code --install-extension ms-vscode-remote.vscode-remote-extensionpack
        # Octave
        code --install-extension paulosilva.vsc-octave-debugger
        code --install-extension toasty-technologies.octave
        # jupyter
        code --install-extension ms-toolsai.jupyter
        ;;
    [Nn]*) ;;
    *) ;;
esac

# install user preferences
read -p "Update user preferences? (y/N): " yn
case $yn in
    [Yy]*)
        DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
        cp -r $DIR/../user/.config/Code/ $HOME/.config/Code/
        ;;
    [Nn]*) ;;

    *) ;;

esac
