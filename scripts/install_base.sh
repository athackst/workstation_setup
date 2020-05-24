#/bin/sh
set -e

# setup sources
sudo apt-get update

sudo apt-get install -y \
  build-essential \
  cmake \
  curl \
  git \
  git-lfs \
  pass \
  snapd \
  ssh \
  wget 
