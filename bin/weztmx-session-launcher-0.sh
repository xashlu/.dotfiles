#!/bin/bash

# Generate a unique socket for each wezterm instance using a random UUID
tmux_socket="wezterm-$(uuidgen | md5sum | cut -d' ' -f1)"

nvim_shada_dir="$HOME/.local/state/nvim/shada"

default_paths_file="$HOME/Desktop/X/I/I/a.txt"
default_variables_file="$HOME/Desktop/X/I/I/a.txt-variables"

# Accept paths file as an argument, fallback to default
paths_file="${1:-$default_paths_file}"
variables_file="$default_variables_file"

rm -rf "$nvim_shada_dir"/* &>/dev/null

[ ! -f "$variables_file" ] && { echo "Variables file missing"; exit 1; }
[ ! -f "$paths_file" ] && { echo "Paths file missing"; exit 1; }
command -v wezterm >/dev/null || { echo "Wezterm not found"; exit 1; }

source "$variables_file"

initial_session=""
while IFS= read -r raw_path; do
    expanded_path="${raw_path//\$D/$D}"
    [ ! -d "$expanded_path" ] && { echo "Invalid directory: $expanded_path"; continue; }
    
    session_name=$(basename "$expanded_path")
    session_name="${session_name%/}"

    if tmux -L "$tmux_socket" has-session -t "$session_name" 2>/dev/null; then
        echo "_REUSE: $session_name ($expanded_path)"
    else
        echo "_CREATE: $session_name ($expanded_path)"
        tmux -L "$tmux_socket" new-session -d -s "$session_name" -n "main" -c "$expanded_path" "bash --login -c 'nvim .'"
        
        window_index=1
        for subdir in "$expanded_path"/*; do
            [ ! -d "$subdir" ] && continue
            subdir_name=$(basename "$subdir")
            [[ "$subdir_name" =~ ^[0-9]+$ ]] && continue
            
            tmux -L "$tmux_socket" new-window -d -t "$session_name:$window_index" \
                -n "$subdir_name" -c "$subdir" "bash --login -c 'nvim .'"
            ((window_index++))
        done
    fi

    [ -z "$initial_session" ] && initial_session="$session_name"
done < "$paths_file"

[ -n "$initial_session" ] && tmux -L "$tmux_socket" attach -t "$initial_session"
