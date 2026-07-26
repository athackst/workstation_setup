#!/bin/bash
set -e

# update the apt repository
sudo apt-get update

# install packages for jekyll
sudo apt-get install -y \
    ruby \
    ruby-bundler \
    ruby-dev \
    rbenv
