#!/bin/bash

# <C-j/k>: scroll
# Get list of tmux sessions
sessions=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows")

# Check if sessions exist
if [ -z "$sessions" ]; then
    tmux display-message "No sessions found"
    exit 1
fi

# Use fzf to select session
selected=$(echo "$sessions" | fzf --height 40% --reverse --inline-info)

if [ -n "$selected" ]; then
    session_name=$(echo "$selected" | cut -d':' -f1 | xargs)
    tmux switch-client -t "$session_name"
else
    tmux display-message "No session selected"
    exit 1
fi
