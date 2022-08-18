#/bin/sh
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# get chrome
read -p "Install chrome? (Y/n): " yn
case $yn in
  [Nn]* ) ;;
  * )
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
  ;;
esac
# get slack
read -p "Install slack? (Y/n): " yn
case $yn in
  [Nn]* ) ;;
  * )
    sudo snap install slack --classic
  ;;
esac

# get sourcegear diffmerge
read -p "Install diffmerge? (Y/n): " yn
case $yn in
  [Nn]* ) ;;
  * )
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
  ;;
esac

# install obs studio
read -p "Install obs studio? (Y/n): " yn
case $yn in
  [Nn]* ) ;;
  * )
    sudo add-apt-repository ppa:obsproject/obs-studio
    sudo apt-get update
    sudo apt-get install -y  ffmpeg obs-studio
  ;;
esac
