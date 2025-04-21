#!/bin/bash

# Determine the browser: Use $BROWSER if set, otherwise find Brave or Firefox
BROWSER=${BROWSER:-$(command -v brave || command -v firefox)}

if [ -z "$BROWSER" ]; then
    echo "No valid web-browser found."
    exit 1
fi

# Set websites directory from argument or default value
websites_dir="${1:-$HOME/Desktop/32}"

# Check if the directory exists
[ -d "$websites_dir" ] || { echo "Directory not found: $websites_dir"; exit 1; }

# Open browser windows for websites from files matching the pattern "*.txt"
for file in "$websites_dir"/*.txt; do
    # Extract the tag number from the filename (e.g., "9a.txt" -> tag 9)
    if [[ "$file" =~ ([0-9]+)[a-zA-Z]*\.txt$ ]]; then
        tag_number="${BASH_REMATCH[1]}"
        
        # Open the browser window with the websites from the file
        [ -f "$file" ] && $BROWSER --new-window $(cat "$file") &
        
        sleep 2  # Give the window time to open
        window_id=$(xdotool search --onlyvisible --class "$(basename $BROWSER)" | head -n 1)

        if [ -n "$window_id" ]; then
            echo "Moving window $window_id to dwm tag $tag_number..."
            xdotool windowmap "$window_id"
            xdotool windowactivate "$window_id"
            sleep 0.1
            xdotool windowfocus "$window_id"
            xdotool key "Alt+Shift+$tag_number"
        else
            echo "Failed to find window ID for $BROWSER. Skipping move."
        fi
    fi
done

echo "All $BROWSER windows launched and moved to their corresponding dwm tags."
