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

cp $DIR/../config/.bash_jekyll $HOME/

# add to .bash_aliases if not already there
if ! grep -Fxq "source ~/.bash_jekyll" ~/.bash_aliases
then
  echo "adding .bash_jekyll to bash_aliases"
  echo "source ~/.bash_jekyll" >> ~/.bash_aliases
fi
