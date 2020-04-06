#/bin/sh
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

source ~/.bashrc