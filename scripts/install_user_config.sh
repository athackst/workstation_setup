#/bin/sh
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# copy example workspace
rm -fr $HOME/.workspace
cp -r $DIR/../user/.workspace/ $HOME/.workspace/

rm -fr $HOME/.aliases
cp -r $DIR/../user/.aliases/ $HOME/.aliases/

# set up aliases
read -p "Replace .bash_aliases? (Y/n): " yn
case $yn in
  "" | [Yy]* )
    if [ -f $HOME/.bash_aliases ]; then
      cp $HOME/.bash_aliases $HOME/.bash_aliases.bak
    fi
    cp $DIR/../user/.bash_aliases* $HOME/
  ;;
esac

# set up git
read -p "Replace .gitconfig? (Y/n): " yn
case $yn in
  "" | [Yy]* )
    if [ -f $HOME/.gitconfig ]; then
      cp $HOME/.gitconfig $HOME/.gitconfig.bak
    fi
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
