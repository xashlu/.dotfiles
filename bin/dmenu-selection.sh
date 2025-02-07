#!/bin/bash

# Use dmenu to prompt for selection
selection=$(echo -e "1-nvim\n2-my_scripts\n3-bash\n4-suckless" | dmenu -p "Choose an option:")

case "$selection" in
    1-nvim)
	wezterm -e bash -l -c "cd \"$HOME/.config/nvim\" && nvim .; exec bash -l"
        ;;
    2-my_scripts)
	wezterm -e bash -l -c "cd \"/$HOME/.local/bin\" && nvim .; exec bash -l"
        ;;
    3-bash)
	wezterm -e bash -l -c "cd \"/$XDG_CONFIG_HOME/bash/\" && nvim .; exec bash -l"
        ;;
    4-suckless)
    wezterm -e bash -l -c "cd \"/$XDG_CONFIG_HOME/suckless/\" && nvim .; exec bash -l"
        ;;
    *)
        echo "Invalid selection or no selection made"
        ;;
esac
