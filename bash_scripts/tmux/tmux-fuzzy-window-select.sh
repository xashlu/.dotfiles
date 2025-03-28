#!/bin/bash

# Get the list of windows in the current tmux session
windows=$(tmux list-windows -F "#{window_index}: #{window_name}")

# Check if windows are available
if [ -z "$windows" ]; then
    echo "No windows found." >&2
    exit 1
fi

# Use fzf to create a fuzzy finder interface in a new terminal
selected=$(echo "$windows" | fzf --height 40% --reverse --inline-info)

# Extract the window index if a selection was made
if [ -n "$selected" ]; then
    window_index=$(echo "$selected" | cut -d':' -f1 | xargs)
    tmux select-window -t "$window_index"
else
    echo "No selection made." >&2
    exit 1
fi
