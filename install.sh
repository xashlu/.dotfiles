#!/bin/bash

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DOTFILES_DIR="$HOME/.dotfiles"

config_links=(
    "$HOME/.bash_profile:$DOTFILES_DIR/bash/.bash_profile"
    "$HOME/.local/bin:$DOTFILES_DIR/bin"
    "$XDG_CONFIG_HOME/bash/.bashrc:$DOTFILES_DIR/bash/.bashrc"
    "$XDG_CONFIG_HOME/tmux/tmux.conf:$DOTFILES_DIR/tmux/tmux.conf"
    "$XDG_CONFIG_HOME/nvim:$DOTFILES_DIR/nvim"
    "$XDG_CONFIG_HOME/X11:$DOTFILES_DIR/X11"
)

for pair in "${config_links[@]}"; do
    IFS=':' read -r target source <<< "$pair"
    source_full="$(realpath "$source")"
    
    mkdir -p "$(dirname "$target")"
    
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        echo "ERROR: $target exists and isn't a symlink. Manual intervention needed."
        exit 1
    fi
    
    ln -s "$source_full" "$target"
    echo "Linked: $target → $source_full"
done

TPM_DIR="$XDG_CONFIG_HOME/tmux/plugins/tpm"
[ ! -d "$TPM_DIR" ] && git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
"$TPM_DIR/scripts/install_plugins.sh"

echo "Setup completed successfully!"
