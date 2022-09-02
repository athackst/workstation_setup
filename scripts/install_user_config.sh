#/bin/sh
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

# set up aliases
read -p "Update .aliases? (Y/n): " yn
case $yn in
  "" | [Yy]*)
    if [ -f $HOME/.aliases ]; then
      mv $HOME/.aliases $HOME/.aliases_bak
    fi
    cp -r $DIR/../user/.aliases $HOME/
    ;;
esac

# set up bash aliases
read -p "Replace .bash_aliases? (Y/n): " yn
case $yn in
  "" | [Yy]*)
    if [ -f $HOME/.bash_aliases ]; then
      mv $HOME/.bash_aliases $HOME/.bash_aliases.bak
    fi
    cp $DIR/../user/.bash_aliases* $HOME/
    ;;
esac

# install user preferences
read -p "Update user .config? (Y/n): " yn
case $yn in
  "" | [Yy]*)
    DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
    cp -r $DIR/../user/.config/ $HOME/.config/
    ;;
esac

# set up git
read -p "Run user-config-update (recommended)? (Y/n): " yn
case $yn in
  "" | [Yy]*)
    $DIR/../programs/user-config-update
    ;;
esac

source ~/.bashrc
