#!/usr/bin/env bash
set -e

# md
# # Dotfiles installation
#
# Set up user configurations including Git configurations (name and email), along with configuring
# several user preferences such as `.aliases`, `.bash_aliases`, and other configurations.
# It provides options for interactive input or automated setup.
#
# ## Basic usage:
#
# ```sh
# install.sh
# ```
# /md

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
auto_yes=false
name=""
email=""
# Path to the user-specific Git config file
git_user_config="$HOME/.gitconfig.user"
# Path to backup directory
BACKUP_DIR="$HOME/bak/config_backup_$(date +%Y%m%d_%H%M%S)"

# Helper function to ask for confirmation with a default value and auto_yes handling
ask_for_confirmation() {
    local prompt="$1"
    local default="${2:-y}" # Default to "y" if not specified

    # If auto_yes is true, automatically accept the default value
    if [ "$auto_yes" = true ]; then
        if [[ "$default" =~ ^[Yy]$ ]]; then
            return 0 # Automatically accept (true)
        else
            return 1 # Automatically decline (false)
        fi
    fi

    # Set the prompt based on the default value
    if [[ "$default" =~ ^[Yy]$ ]]; then
        prompt="$prompt (Y/n): "
        default_choice="y"
    elif [[ "$default" =~ ^[Nn]$ ]]; then
        prompt="$prompt (y/N): "
        default_choice="n"
    else
        echo "Invalid default value: $default"
        return 1
    fi

    # Ask the question and read user input
    read -p "$prompt" -n 1 -r
    echo

    # Determine the answer
    if [[ -z "$REPLY" ]]; then
        # If no input, use the default value
        REPLY="$default_choice"
    fi

    [[ "$REPLY" =~ ^[Yy]$ ]]
}

# Helper function to get user input
ask_for_input() {
    local prompt="$1"
    local variable="$2"
    local default="$3"
    # Return if the variable is already assigned
    if [ -n "${!variable}" ]; then
        return
    fi
    # If auoto_yes is true, automatically accept the default value
    if [ "$auto_yes" = true ] && [ -n "$default" ]; then
        eval "$variable=\"$default\""
        return
    fi
    read -p "$prompt" input
    eval "$variable=\"\${input:-$default}\""
}

# Helper function to backup a file
backup_file() {
    local path="$1"
    if [ -e "$path" ] || [ -L "$path" ]; then
        local basename=$(basename "$path")
        mkdir -p "$BACKUP_DIR"
        cp -rL "$path" "$BACKUP_DIR/$basename"
        echo "Backed up contents of $path to $BACKUP_DIR/$basename"
    else
        echo "Path $path does not exist, skipping backup"
    fi
}

# md
# ### Command Line Arguments
#
# The following section parses command-line arguments using `getopts`:
# 
# - `-i` : Enables interactive mode and will prompt each step.
# - `-e <email>` : Sets the Git user email.
# - `-n <name>` : Sets the Git user name.
#
# /md

auto_yes=true
while getopts ":ye:n:" opt; do
    case ${opt} in
        i)
            auto_yes=false
            ;;
        e)
            email=$OPTARG
            ;;
        n)
            name=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

# md
# ## What this script does
# /md

# md
# ### Git User Name and Email Setup
#
# The script sets up the Git user name and email in `$HOME/.gitconfig.user``. 
# If the name or email is not provided, the script prompts the user for it. 
# The provided name is stored in `.gitconfig.user` to be used globally in Git.
#
# If left blank, the script will skip this step.
# /md

# Make sure the config file exists
if [ ! -f "$git_user_config" ] || ! grep -q '^\[user\]' "$git_user_config"; then
    touch $git_user_config
    echo "[user]" >> "$git_user_config";
    ask_for_input "Enter the name you want to use for git (optional): " name "Allison Thackston"
    ask_for_input "Enter the email address you want to use for git (optional): " email "allison@allisonthackston.com"
    # Validate that the name is not empty if it needs to be set
    if [ -n "$name" ] && [ -n "$email" ]; then
        echo "Setting name and email in $git_user_config to $name and $email"
        # Add the user name to the file
        cat > "$git_user_config" << EOF
[user]
    name = $name
    email = $email
EOF
    else 
        echo "Need name and email for git config, skipping."
    fi
else
    # Update the existing user.name in the file
    echo "User config already set in $git_user_config, skipping."
fi

# md
# ### Configure Aliases
#
# The script sets up the `.aliases` directory. It creates a backup of the existing `.aliases` if present,
# and then links the new `.aliases` from the repository to the user's home directory.
# /md
if ask_for_confirmation "Update .aliases?"; then
    if [ -d "$HOME/.aliases" ]; then
        if [ -d "$HOME/.aliases_bak" ]; then
            rm -rf "$HOME/.aliases_bak"
        fi
        echo "Backing up $HOME/.aliases to $HOME/.aliases_bak"
        cp -rL "$HOME/.aliases" "$HOME/.aliases_bak"
        rm -rf "$HOME/.aliases"
    fi
    ln -sfn "$DIR/dotfiles/.aliases" "$HOME/.aliases"
    echo "Linked $HOME/.aliases to $DIR/dotfiles/.aliases"
else
    echo "Skipping .aliases"
fi

# md
# ### Configure Bash Aliases
#
# The script sets up `.bash_aliases`. It backs up the existing `.bash_aliases` and then creates
# a symbolic link to the new one from the repository.
# /md
if ask_for_confirmation "Update .bash_aliases?"; then
    if [ -f "$HOME/.bash_aliases" ]; then
        echo "Backing up $HOME/.bash_aliases to $HOME/.bash_aliases.bak"
        cp "$HOME/.bash_aliases" "$HOME/.bash_aliases.bak"
    fi
    ln -sf "$DIR/dotfiles/.bash_aliases" "$HOME/.bash_aliases"
    echo "Linked $HOME/.bash_aliases to $DIR/dotfiles/.bash_aliases"
else
    echo "Skipping .bash_aliases"
fi

# md
# ### Configure Gitconfig
#
# The script sets up `.gitconfig`. It creates a backup of the existing `.gitconfig` and then
# creates a symbolic link to the new one from the repository.
# /md
if ask_for_confirmation "Update .gitconfig?"; then
    if [ -f "$HOME/.gitconfig" ]; then
        echo "Backing up $HOME/.gitconfig to $HOME/.gitconfig.bak"
        cp "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
    fi
    ln -sf "$DIR/dotfiles/.gitconfig" "$HOME/.gitconfig"
    echo "Linked $HOME/.gitconfig to $DIR/dotfiles/.gitconfig"
else
    echo "Skipping .gitconfig"
fi

# md
# ### Configure User Preferences in .config
#
# The script sets up user preferences in the `.config` directory.
# It creates symbolic links to individual configuration files in `$HOME/.config`.
# /md
if ask_for_confirmation "Update user .config?"; then
    echo "Setting up .config directory..."
    find "$DIR/dotfiles/.config" -type f | while read -r item; do
        relative_path="${item#$DIR/dotfiles/.config/}"
        target="$HOME/.config/$relative_path"
        target_dir=$(dirname "$target")
        mkdir -p "$target_dir"
        if [ -e "$target" ]; then
            echo "Backing up $target to $target.bak"
            mv "$target" "$target.bak"
        fi
        ln -sfn "$item" "$target"
        echo "Linked $target to $item"
    done
    echo "Config files updated."
else
    echo "Skipping syncing .config"
fi
