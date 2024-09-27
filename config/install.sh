#/bin/sh
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

# Helper function to ask for confirmation
ask_for_confirmation() {
	local prompt="$1"

	read -p "$prompt (y/n): " -n 1 -r
	echo
	[[ $REPLY =~ ^[Yy]$ ]]
}

# Parse command line options using getopts
auto_yes=false

while getopts ":y" opt; do
	case ${opt} in
		y )
			auto_yes=true
			;;
		\? )
			echo "Invalid option: - $OPTARG" >&2
			exit 1
			;;
	esac
done
shift $(( OPTIND -1))

# set up aliases
if $auto_yes || ask_for_confirmation "Update .aliases?"; then
    if [ -f $HOME/.aliases ]; then
      mv $HOME/.aliases $HOME/.aliases_bak
    fi
    cp -r $DIR/user/.aliases $HOME/
else
  echo "Skipping .aliases"
fi

# set up bash aliases
if $auto_yes || ask_for_confirmation "Replace .bash_aliases?"; then
    if [ -f $HOME/.bash_aliases ]; then
      mv $HOME/.bash_aliases $HOME/.bash_aliases.bak
    fi
    cp $DIR/user/.bash_aliases* $HOME/
else
  echo "Skipping .bash_aliases"
fi

# install user preferences
if $auto_yes || ask_for_confirmation "Update user .config?"; then
    # Use rsync instead of cp for more control
    rsync -av --ignore-existing "$DIR/user/.config/" "$HOME/.config/"

    echo "Config files updated. Existing files were not overwritten."
else
  echo "Skipping syncing .config"
fi

# set up user config
if $auto_yes || ask_for_confirmation "Add user_config aliases?"; then
    echo "alias user_config_update=$DIR/user-config-update.sh" >> $HOME/.bash_aliases
    echo "alias user_config_diff=$DIR/user-config-diff.sh" >> $HOME/.bash_aliases
    source ~/.bash_aliases
    echo "Run user_config_update to sync your user config settings to this base."
else
  echo "Skipping adding user config aliases"
fi
