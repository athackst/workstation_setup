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
  wget 

# get chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# get slack
sudo snap install slack --classic

# get source gear diffmerge
# NOTE: diffmerge is no longer supported by debian from sourcegear in Ubuntu 18.04
# wget -O - http://debian.sourcegear.com/SOURCEGEAR-GPG-KEY | sudo apt-key add -
# sudo sh -c 'echo "deb http://debian.sourcegear.com/ubuntu `lsb_release -cs` main" >> /etc/apt/sources.list.d/sourcegear.list'
# sudo apt-get update
# sudo apt-get install -y diffmerge

# set up git
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cp $DIR/../config/.gitconfig $HOME/.gitconfig
