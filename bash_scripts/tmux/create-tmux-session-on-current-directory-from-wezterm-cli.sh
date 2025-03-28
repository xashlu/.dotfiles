#!/bin/bash
# A_v2: Create a tmux session on the current directory from WezTerm CLI

# Define the path to nvim shada files (using $HOME)
nvim_shada_dir="$HOME/.local/state/nvim/shada"
echo "Cleaning nvim shada files in $nvim_shada_dir..."
rm -rf "$nvim_shada_dir"/*

# Use the current working directory (using $PWD)
base_dir="$PWD"
session_name=$(basename "$base_dir")

# Check if a tmux session with the same name already exists
if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "tmux session '$session_name' already exists. Attaching..."
    tmux attach-session -t "$session_name"
    exit 0
fi

echo "Creating tmux session: $session_name"
tmux new-session -d -s "$session_name" -n "main" "bash --login -c 'cd \"$base_dir\" && nvim .'"

window_index=1
for subdir in "$base_dir"/* "$base_dir"/.*; do
    # Skip "." and ".." to prevent infinite loops
    [[ "$subdir" == "$base_dir/." || "$subdir" == "$base_dir/.." ]] && continue

    if [[ -d "$subdir" ]]; then
        subdir_name=$(basename "$subdir")

        # Skip numeric subdirectories if desired
        if [[ "$subdir_name" =~ ^[0-9]+$ ]]; then
            echo "Skipping numeric subdirectory: $subdir_name"
            continue
        fi

        # Ensure that directories starting with a dot are handled
        if [[ "$subdir_name" =~ ^\..* ]]; then
            # Handle directory names starting with a dot by renaming it for tmux
            subdir_name_for_tmux=$(echo "$subdir_name" | sed 's/^\.//')
            tmux new-window -t "$session_name:$window_index" -n "$subdir_name_for_tmux" "bash --login -c 'cd \"$subdir\" && nvim .'"
        else
            tmux new-window -t "$session_name:$window_index" -n "$subdir_name" "bash --login -c 'cd \"$subdir\" && nvim .'"
        fi
        
        ((window_index++))
    fi
done

echo "Attaching to tmux session: $session_name"
tmux attach-session -t "$session_name"

