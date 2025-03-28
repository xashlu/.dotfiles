#!/bin/bash
# Description: A fuzzy dir navigator using fzf

# Store the initial directory (the directory from which the script is launched)
initial_directory=$(pwd)

# Variable to store the last valid selection
last_selection=""

while true; do
    # Store the current directory name
    current_directory=$(pwd)

    # List files and directories in the current path
    files=$(find . -mindepth 1 -maxdepth 1 -printf '%P\n')

    # Use fzf to capture selection and key press
    selection=$(echo "$files" | fzf --bind 'tab:accept' --bind "esc:abort" \
        --header 'Press Tab to enter directories, Enter to change to last selected item, Esc to quit' --expect tab,enter,esc)

    # The key pressed (tab, enter, or esc)
    key=$(echo "$selection" | head -n 1)
    # The selected file or directory
    selection=$(echo "$selection" | tail -n 1)

    if [[ "$key" == "esc" ]]; then
        cd "$initial_directory"
        break
    elif [[ "$key" == "enter" ]]; then
        # Change to the last valid selection
        if [[ -n "$last_selection" ]]; then
            cd "$last_selection" && break || {
                echo "Failed to change directory to: $last_selection"
                break
            }
        else
            echo "No previous selection to change to."
        fi
        continue
    elif [[ "$key" == "tab" && -n "$selection" ]]; then
        # Store the full path of the selected item
        last_selection="$(pwd)/$selection"
        if [[ -d "$last_selection" ]]; then
            cd "$last_selection" || {
                echo "Failed to change directory to: $last_selection"
                break
            }
        elif [[ -f "$last_selection" ]]; then
            echo "Opening file: $last_selection"
            $EDITOR "$last_selection" 
        fi
        continue
    else
        echo "No valid selection made."
        break
    fi
done
