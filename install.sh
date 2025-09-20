#!/usr/bin/env bash
set -euo pipefail

# md
# # Dotfiles installation
#
# Set up user configurations including Git configurations (name and email), along with configuring
# several user preferences such as `.aliases`, `.bash_aliases`, and other configurations.
# It provides options for interactive input or automated setup.
#
# ## Quickstart
#
# ```sh
# git clone https://www.github.com/athackst/workstation_setup
# cd workstation_setup
# ./install.sh
# ```
#
# ## Usage:
#
# ```sh
# ./install.sh [-i] [-e EMAIL] [-n NAME] [-m symlink|copy] [-h]
#   -i            Interactive mode (prompts before actions)
#   -e EMAIL      Set git user.email
#   -n NAME       Set git user.name
#   -m MODE       Install mode: 'symlink' (default) or 'copy'
#   -h            Help
# ```
# /md
# --- paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DOTROOT="$SCRIPT_DIR/dotfiles"
BINROOT="$SCRIPT_DIR/scripts/bin"

if [ -d "$BINROOT" ]; then
    find "$BINROOT" -maxdepth 1 -type f -exec chmod +x -- {} + || true
fi

# --- defaults / state ---
auto_yes=true               # -i toggles this off (prompting)
INSTALL_MODE="symlink"      # or "copy" via -m
name="${name:-}"            # allow env to preseed
email="${email:-}"
git_user_config="$HOME/.gitconfig.user"
backup_root="$HOME/bak/config_backup_$(date +%Y%m%d_%H%M%S)"

# --- helpers ---
show_usage() {
cat <<EOF
Usage: $0 [-i] [-e EMAIL] [-n NAME] [-m symlink|copy] [-h]
  -i                 Run interactively (ask before each step)
  -e EMAIL           Set git user.email
  -n NAME            Set git user.name
  -m MODE            Installation mode: 'symlink' (default) or 'copy'
  -h                 Show this help
Examples:
  $0 -e "you@example.com" -n "Your Name"
  $0 -m copy
  $0 -i -m symlink
EOF
}

have() { command -v "$1" >/dev/null 2>&1; }

ask_for_confirmation() {
    local prompt="$1"
    local default="${2:-y}"  # y/n
    local default_choice
    if "$auto_yes"; then
        [[ "$default" =~ ^[Yy]$ ]] && return 0 || return 1
    fi
    if [[ "$default" =~ ^[Yy]$ ]]; then
        prompt="$prompt (Y/n): "; default_choice="y"
    elif [[ "$default" =~ ^[Nn]$ ]]; then
        prompt="$prompt (y/N): "; default_choice="n"
    else
        echo "Invalid default: $default" >&2; return 1
    fi
    read -rp "$prompt" -n 1 REPLY || true
    echo
    [[ -z "$REPLY" ]] && REPLY="$default_choice"
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

# ask_for_input PROMPT VAR DEFAULT
ask_for_input() {
    local prompt="$1" var="$2" default="${3:-}"
    # if already set (via -e/-n/env), skip
    if [ -n "${!var:-}" ]; then return; fi
    if "$auto_yes" && [ -n "$default" ]; then
        printf -v "$var" "%s" "$default"; return
    fi
    read -rp "$prompt" tmp || true
    printf -v "$var" "%s" "${tmp:-$default}"
}

ensure_path() {
    mkdir -p "$HOME/.local/bin"
    add_line='export PATH="$HOME/.local/bin:$PATH"'
    for rc in .profile .bashrc .zshrc; do
        [ -f "$HOME/$rc" ] || touch "$HOME/$rc"
        if ! grep -qsF "$add_line" "$HOME/$rc"; then
            echo "$add_line" >> "$HOME/$rc"
        fi
    done
    # Also make it available to this session
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
}

# Back up a file/dir/symlink to a timestamped folder (preserves symlinks/perms)
backup_path() {
    local src="$1"
    if [ ! -e "$src" ] && [ ! -L "$src" ]; then
        echo "skip backup: $src (does not exist)"; return
    fi
    mkdir -p "$backup_root"
    local base; base="$(basename -- "$src")"
    local dest="$backup_root/$base"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        dest="${dest}_$RANDOM"
    fi
    if have rsync; then
        rsync -a -- "$src" "$dest"
    else
        cp -a -- "$src" "$dest"
    fi
    echo "Backed up $src -> $dest"
}

deploy_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname -- "$dst")"
    if [ "$INSTALL_MODE" = "copy" ]; then
        backup_path "$dst"
        if have rsync; then rsync -a -- "$src" "$dst"; else cp -a -- "$src" "$dst"; fi
    else
        ln -sfn -- "$src" "$dst"
    fi
    echo "Installed: $dst"
}

deploy_dir() {
    local src="$1" dst="$2"
    if [ "$INSTALL_MODE" = "copy" ]; then
        backup_path "$dst"
        mkdir -p "$dst"
        if have rsync; then
            rsync -a --delete -- "$src"/ "$dst"/
        else
            # Fallback without rsync (no delete)
            cp -a -- "$src"/. "$dst"/
        fi
    else
        # symlink the directory as a whole
        if [ -e "$dst" ] || [ -L "$dst" ]; then
            backup_path "$dst"
            rm -rf -- "$dst"
        fi
        ln -sfn -- "$src" "$dst"
    fi
    echo "Installed dir: $dst"
}

deploy_config_tree() {
    local src_root="$1" dst_root="$2"
    echo "Syncing config tree: $src_root -> $dst_root"
    find "$src_root" \( -type f -o -type l \) -print0 | while IFS= read -r -d '' item; do
        local rel="${item#$src_root/}"
        local dst="$dst_root/$rel"
        mkdir -p "$(dirname -- "$dst")"
        if [ "$INSTALL_MODE" = "copy" ]; then
            backup_path "$dst"
            if have rsync; then rsync -a -- "$item" "$dst"; else cp -a -- "$item" "$dst"; fi
        else
            ln -sfn -- "$item" "$dst"
        fi
        echo "  -> $dst"
    done
}

# --- parse flags ---
while getopts ":ie:n:m:h" opt; do
    case "$opt" in
        i) auto_yes=false ;;
        e) email="$OPTARG" ;;
        n) name="$OPTARG" ;;
        m) INSTALL_MODE="$OPTARG" ;;
        h) show_usage; exit 0 ;;
        :) echo "Error: option -$OPTARG requires an argument" >&2; show_usage; exit 2 ;;
        \?) echo "Error: unknown option -$OPTARG" >&2; show_usage; exit 2 ;;
    esac
done
shift "$((OPTIND - 1))"

# md
# ### Modes
#
# - symlink (default): Creates/refreshes symlinks in $HOME. Fast and idempotent.
# - copy: Copies files/dirs and creates a timestamped backup in ~/bak/config_backup_YYYYmmdd_HHMMSS before overwriting.
#
# The script also ensures ~/.local/bin exists and is on your PATH.
#
# /md
# --- validate mode ---
case "$INSTALL_MODE" in
    symlink|copy) ;;
    *) echo "Invalid -m MODE: $INSTALL_MODE (use 'symlink' or 'copy')" >&2; exit 2 ;;
esac

echo "Mode: $INSTALL_MODE"
"$auto_yes" || echo "(interactive mode)"

# --- sanity checks ---
if [ ! -d "$DOTROOT" ]; then
    echo "ERROR: Expected dotfiles directory at: $DOTROOT" >&2
    exit 1
fi

# md
# ### Git identity (~/.gitconfig.user)
#
# This script will also set up the git identity of the user
#
# - Non-interactive: Only fills missing user.name / user.email (does not override existing values).
# - Interactive: You’ll be asked once whether to update; if yes, values are written.
#
# In either case, if the file is changed, it’s backed up first.
#
# Uses git config --file ~/.gitconfig.user to update keys (no full-file overwrite).
# /md

# --- Git user config (~/.gitconfig.user) ---
if have git; then
    # Gather values (flags/env override prompts; defaults used otherwise)
    ask_for_input "Enter the name you want to use for git (optional): " name  "Allison Thackston"
    ask_for_input "Enter the email address you want to use for git (optional): " email "allison@allisonthackston.com"
    
    # Read existing values if any
    existing_name="$(git config --file "$git_user_config" --get user.name 2>/dev/null || true)"
    existing_email="$(git config --file "$git_user_config" --get user.email 2>/dev/null || true)"
    
    # - Non-interactive: update only missing fields (don't override existing).
    # - Interactive: ask once; if yes, update fields provided (even if they match defaults).
    do_update_name=false
    do_update_email=false
    
    if "$auto_yes"; then
        # non-interactive
        if [ -z "$existing_name" ] && [ -n "$name" ]; then do_update_name=true; fi
        if [ -z "$existing_email" ] && [ -n "$email" ]; then do_update_email=true; fi
    else
        # interactive
        if ask_for_confirmation "Update $git_user_config with name='$name', email='$email'?" "y"; then
            [ -n "$name" ]  && do_update_name=true
            [ -n "$email" ] && do_update_email=true
        fi
    fi
    
    if $do_update_name || $do_update_email; then
        if [ -e "$git_user_config" ] || [ -L "$git_user_config" ]; then
            backup_path "$git_user_config"
        fi
        mkdir -p "$(dirname -- "$git_user_config")"
        touch "$git_user_config"  # ensure file exists; do NOT truncate
        if $do_update_name;  then git config --file "$git_user_config" user.name  "$name";  fi
        if $do_update_email; then git config --file "$git_user_config" user.email "$email"; fi
        echo "Updated $git_user_config (name: $do_update_name, email: $do_update_email)."
    else
        echo "No changes to $git_user_config"
    fi
else
    echo "git not found; skipping git identity setup."
fi

# Ensure ~/.local/bin exists + on PATH (useful for your scripts)
ensure_path

# --- .aliases (directory) ---
if [ -d "$DOTROOT/.aliases" ] && ask_for_confirmation "Install .aliases?"; then
    deploy_dir "$DOTROOT/.aliases" "$HOME/.aliases"
else
    echo "Skipping .aliases"
fi

# --- .bash_aliases (file) ---
if [ -f "$DOTROOT/.bash_aliases" ] && ask_for_confirmation "Install .bash_aliases?"; then
    deploy_file "$DOTROOT/.bash_aliases" "$HOME/.bash_aliases"
else
    echo "Skipping .bash_aliases"
fi

# --- .gitconfig (file) ---
if [ -f "$DOTROOT/.gitconfig" ] && ask_for_confirmation "Install .gitconfig?"; then
    deploy_file "$DOTROOT/.gitconfig" "$HOME/.gitconfig"
else
    echo "Skipping .gitconfig"
fi

# --- ~/.config tree (files/symlinks within) ---
if [ -d "$DOTROOT/.config" ] && ask_for_confirmation "Sync dotfiles/.config into ~/.config?"; then
    mkdir -p "$HOME/.config"
    deploy_config_tree "$DOTROOT/.config" "$HOME/.config"
else
    echo "Skipping ~/.config sync"
fi

# --- ~/.local/bin (optional scripts) ---
if [ -d "$BINROOT" ] && ask_for_confirmation "Install scripts to ~/.local/bin?"; then
    find "$BINROOT" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' f; do
        local_name="$(basename -- "$f")"
        deploy_file "$f" "$HOME/.local/bin/$local_name"
        if [ "$INSTALL_MODE" = "copy" ] && [ ! -x "$HOME/.local/bin/$local_name" ]; then
            chmod +x "$HOME/.local/bin/$local_name" || true
        fi
    done
else
    echo "No $BINROOT found or opted to skip."
fi

echo "Done."
