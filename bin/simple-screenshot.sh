#!/bin/bash

screenshot_dir="/tmp"
screenshot_file="$screenshot_dir/selection_screenshot_$(date +%Y%m%d%H%M%S).png"

scrot -s "$screenshot_file"
if [ $? -eq 0 ]; then
    xclip -selection clipboard -t image/png -i "$screenshot_file"
    if [ $? -eq 0 ]; then
        echo "Screenshot saved to clipboard!"
    else
        echo "Error: Failed to save screenshot to clipboard."
    fi
else
    echo "Error: Failed to take screenshot."
fi
