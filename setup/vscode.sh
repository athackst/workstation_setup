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


read -p "Install vscode extensions? (y/N): " yn
case $yn in
    [Yy]*)
        # Keep generally useful desktop extensions here. Language runtimes,
        # debuggers, and other project-specific extensions belong in each
        # repository's devcontainer configuration.
        extensions=(
            analytic-signal.preview-pdf
            davidanson.vscode-markdownlint
            eamodio.gitlens
            esbenp.prettier-vscode
            github.vscode-github-actions
            github.vscode-pull-request-github
            ms-vscode-remote.vscode-remote-extensionpack
            openai.chatgpt
            redhat.vscode-yaml
            streetsidesoftware.code-spell-checker
            yzhang.markdown-all-in-one
        )

        for extension in "${extensions[@]}"; do
            code --install-extension "$extension"
        done
        ;;
    [Nn]*) ;;
    *) ;;
esac

# install user preferences
read -p "Update user preferences? (y/N): " yn
case $yn in
    [Yy]*)
        DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
        cp -r "$DIR/../dotfiles/.config/Code/" "$HOME/.config/Code/"
        ;;
    [Nn]*) ;;

    *) ;;

esac
