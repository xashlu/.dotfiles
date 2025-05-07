#!/bin/bash

# Enable optional debugging
DEBUG=0

log_debug() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown Time")
    [ "$DEBUG" -eq 1 ] && printf "[DEBUG] [%s] %s\n" "$timestamp" "$1"
}

# Get working directory from argument
CURRENT_DIR="$1"
if [ -z "$CURRENT_DIR" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

TAG=2

# Function to launch terminal and move to tag
launch_and_place_terminal() {
    wezterm start --cwd "$CURRENT_DIR"
    sleep 1

    # Find newest window
    WIN_ID=$(xdotool search --onlyvisible --class WezTerm | tail -n 1)

    if [ -n "$WIN_ID" ]; then
        xdotool windowactivate --sync "$WIN_ID"

        # Move to tag 2
        xdotool key --clearmodifiers alt+shift+11

        # Switch to tag 2
        xdotool key --clearmodifiers alt+11

        # Focus and return window ID
        xdotool windowfocus "$WIN_ID"
        sleep 0.3
        echo "$WIN_ID"
    else
        echo "Failed to find terminal window!" >&2
        exit 1
    fi
}

# Step 1: Launch first terminal, move to tag 2, run nvim .
echo "Launching first terminal..."
WIN1=$(launch_and_place_terminal)
xdotool windowfocus "$WIN1"
xdotool type 'nvim .'
xdotool key Return

# Step 2: Go back to tag 1
xdotool key --clearmodifiers alt+10

# Step 3: Launch second terminal, move to tag 2
echo "Launching second terminal..."
WIN2=$(launch_and_place_terminal)
xdotool windowfocus "$WIN2"
xdotool type 'pa'
xdotool key Return

echo "Done! Workspace set up on dwm tag $TAG"
