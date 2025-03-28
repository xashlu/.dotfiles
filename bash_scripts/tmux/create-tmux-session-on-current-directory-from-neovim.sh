#!/bin/bash

# Define the path to nvim shada files (use uppercase HOME)
nvim_shada_dir="$HOME/.local/state/nvim/shada"

# Clean the nvim shada files
echo "Cleaning nvim shada files in $nvim_shada_dir..."
rm -rf "$nvim_shada_dir"/*

# Get the current working directory (use uppercase PWD)
base_dir="$PWD"

# Get the session name from the current directory name
session_name=$(basename "$base_dir")

# Check if tmux session already exists
if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "tmux session '$session_name' already exists. Attaching..."
    tmux attach-session -t "$session_name"
    exit 0
fi

# Create the tmux session with the current directory
echo "Creating tmux session: $session_name"
tmux new-session -d -s "$session_name" -n "main" "bash --login -c 'cd \"$base_dir\" && nvim .'"

# Add a window for each subdirectory
window_index=1
for subdir in "$base_dir"/*; do
    if [[ -d "$subdir" ]]; then
        subdir_name=$(basename "$subdir")
        
        if [[ "$subdir_name" =~ ^[0-9]+$ ]]; then
            echo "Skipping numeric subdirectory: $subdir_name"
            continue
        fi

        echo "Creating tmux window for subdirectory: $subdir_name in session $session_name"
        tmux new-window -t "$session_name:$window_index" -n "$subdir_name" "bash --login -c 'cd \"$subdir\" && nvim .'"
        ((window_index++))
    fi
done

# Attach to the tmux session
echo "Attaching to tmux session: $session_name"
tmux attach-session -t "$session_name"
