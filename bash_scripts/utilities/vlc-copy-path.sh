#!/bin/bash

# vlc-copy-path - Copy currently playing .mp4 file path from VLC to clipboard

# Get the current MP4 path from VLC and copy to clipboard
lsof -c vlc | awk '/\.mp4$/ {print $9}' | xclip -selection clipboard

# Optional: Notify user
if [ $? -eq 0 ]; then
    notify-send "VLC Path Copied" "$(xclip -selection clipboard -o)"
fi
