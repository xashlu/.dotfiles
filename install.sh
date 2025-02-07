#!/bin/bash

ln -sf "$HOME/.dotfiles/bash/bash_profile" "$HOME/.bash_profile"
ln -sf "$HOME/.dotfiles/bash/bashrc" "$HOME/.config/bash/.bashrc"
ln -sf "$HOME/.dotfiles/bin" "$HOME/.local/bin"

echo "Dotfiles successfully linked!"
