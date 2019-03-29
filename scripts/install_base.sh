#/bin/sh
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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
sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# get slack
sudo snap install slack --classic

# get sourcegear diffmerge 
# NOTE: diffmerge is no longer supported by debian from sourcegear in Ubuntu 18.04
sudo apt install -y libcanberra-gtk-module libcanberra-gtk3-module python python-requests
python $DIR/google_drive.py 1sj_6QHV15tIzQBIGJaopMsogyds0pxD9 /tmp/diffmerge_4.2.1.817.beta_amd64.deb
sudo dpkg -i /tmp/diffmerge_4.2.1.817.beta_amd64.deb
sudo apt-get install -f -y

# Original 16.04 instructions
# wget -O - http://debian.sourcegear.com/SOURCEGEAR-GPG-KEY | sudo apt-key add -
# sudo sh -c 'echo "deb http://debian.sourcegear.com/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/sourcegear.list'
# sudo apt-get update
# sudo apt-get install -y diffmerge

# set up git
cp $DIR/../config/.gitconfig $HOME/.gitconfig
cp $DIR/../config/.bash_aliases $HOME/
