#/bin/sh
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# copy example workspace
rm -fr $HOME/.workspace
cp -r $DIR/../user/.workspace/ $HOME/.workspace/

# set up aliases
read -p "Replace .bash_aliases? (Y/n): " yn
case $yn in
  "" | [Yy]* )
    cp $DIR/../user/.bash_aliases* $HOME/
  ;;
esac

# set up git
read -p "Replace .gitconfig? (Y/n): " yn
case $yn in
  "" | [Yy]* )
    cp $DIR/../user/.gitconfig $HOME/
  ;;
esac

# install user preferences
read -p "Update user preferences? (Y/n): " yn
case $yn in
  "" | [Yy]* )
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    cp -r $DIR/../user/.config/ $HOME/.config/
    cp -r $DIR/../user/.ignition/ $HOME/.ignition/
  ;;
esac

source ~/.bashrc