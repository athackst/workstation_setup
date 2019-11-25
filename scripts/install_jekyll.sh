#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# update the apt repository
sudo apt-get update

# install packages for jekyll
sudo apt-get install -y \
    ruby \
    ruby-dev \
    rbenv

# install bundler
gem install bundler --user

# install pre-reqs for github-pages
sudo apt-get install -y \
    build-essential \
    libxml2 \
    libxml2-dev
    # libxslt