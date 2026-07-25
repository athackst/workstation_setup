#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# update the apt repository
sudo apt-get update

# install packages for jekyll
sudo apt-get install -y \
    ruby \
    ruby-bundler \
    ruby-dev \
    rbenv
