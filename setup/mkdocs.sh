#/bin/sh
set -e

sudo apt-get update
sudo apt-get install -y python3-pip

pip3 install \
    mkdocs-awesome-pages-plugin \
    mkdocs-macros-plugin \
    mkdocs-material \
    mkdocs-simple-plugin \
    mkdocs \
    mkdocstrings \
    mkdocstrings-python-legacy \
    mike
