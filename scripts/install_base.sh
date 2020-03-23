#/bin/sh
set -e

# setup sources
sudo apt-get update

sudo apt-get install -y \
  build-essential \
  cmake \
  curl \
  git \
  pass \
  snapd \
  ssh \
  wget 
