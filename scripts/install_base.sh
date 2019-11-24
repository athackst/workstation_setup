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
  ssh \
  wget 

# get chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# get slack
sudo snap install slack --classic

# get sourcegear diffmerge 
if [[ `lsb_release -cs` == "bionic" ]]
then
  # NOTE: diffmerge is no longer supported by debian from sourcegear in Ubuntu 18.04
  sudo apt install -y libcanberra-gtk-module libcanberra-gtk3-module python python-requests
  python $DIR/google_drive.py 1sj_6QHV15tIzQBIGJaopMsogyds0pxD9 /tmp/diffmerge_4.2.1.817.beta_amd64.deb
  sudo dpkg -i /tmp/diffmerge_4.2.1.817.beta_amd64.deb
  sudo apt-get install -f -y
else
  # Original 16.04 instructions
  wget http://download.sourcegear.com/DiffMerge/4.2.0/diffmerge_4.2.0.697.stable_amd64.deb
  sudo dpkg -i diffmerge_4.2.0.*.deb
  rm diffmerge_4.2.0.*.deb 
fi

# copy example workspace
rm -fr $HOME/.workspace
cp -r $DIR/../config/.workspace/ $HOME/.workspace/

# set up aliases
read -p "Replace .bash_aliases? (y/N): " yn
case $yn in
  [Yy]* ) cp $DIR/../config/.bash_aliases $HOME/.bash_aliases;;
  [Nn]* ) ;;
  * )     ;; 
esac

# set up gitconfig
read -p "Replace .gitconfig? (y/N): " yn
case $yn in
  [Yy]* ) cp $DIR/../config/.gitconfig $HOME/.gitconfig;;
  [Nn]* ) ;;
  * )     ;;
esac