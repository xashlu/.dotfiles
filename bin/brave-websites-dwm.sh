#!/bin/bash

# Define the directory where the website files are stored
websites_dir="$HOME/Desktop/.brave-websites"

# Check if the directory exists
if [ ! -d "$websites_dir" ]; then
    echo "Directory not found: $websites_dir"
    exit 1
fi

# Open the Brave windows for the website files from 1.txt to 8.txt
for i in {1..8}; do
    websites_file="$websites_dir/$i.txt"

    # Check if the file exists
    if [ -f "$websites_file" ]; then
        echo "Opening websites from $websites_file in Brave..."

        # Open Brave with the websites from the file in a new window
        brave --new-window $(cat "$websites_file") &

        # Wait for the Brave window to open (give it enough time)
        sleep 2  # Adjust this sleep time if needed

        # Get the window ID associated with the Brave process
        window_id=$(xdotool search --onlyvisible --class "Brave" | head -n 1)

        # Ensure that the window ID is found before moving it
        if [ -n "$window_id" ]; then
            # Move the Brave window to the correct dwm tag
            echo "Moving window $window_id to dwm tag $i..."
            xdotool windowmap "$window_id"  # Ensure the window is mapped
            xdotool windowactivate "$window_id"  # Activate the window before moving
            sleep 0.1  # Wait just a bit after activation for consistency
            xdotool windowfocus "$window_id"  # Focus the window again
            xdotool key "Alt+Shift+$i"  # Move window to dwm tag
        else
            echo "Failed to find window ID for Brave window. Skipping move."
        fi
    else
        echo "No file found: $websites_file"
    fi
done

# Open two separate Brave windows for dwm tag 9 with different websites
echo "Opening two separate Brave windows for dwm tag 9..."

# Brave instance 1 (for tag 9)
brave --new-window $(cat "$websites_dir/9a.txt") &

# Brave instance 2 (for tag 9)
brave --new-window $(cat "$websites_dir/9b.txt") &

# Wait for the Brave windows to open (give them enough time)
sleep 2

# Get the window IDs associated with the Brave process (for tag 9)
window_id_1=$(xdotool search --onlyvisible --class "Brave" | head -n 1)
window_id_2=$(xdotool search --onlyvisible --class "Brave" | tail -n 1)

# Ensure that the window IDs are found before moving them
if [ -n "$window_id_1" ] && [ -n "$window_id_2" ]; then
    # Move the Brave windows to dwm tag 9
    echo "Moving window $window_id_1 to dwm tag 9..."
    xdotool windowmap "$window_id_1"  # Ensure the window is mapped
    xdotool windowactivate "$window_id_1"  # Activate the window before moving
    sleep 0.1  # Wait just a bit after activation for consistency
    xdotool windowfocus "$window_id_1"  # Focus the window again
    xdotool key "Alt+Shift+9"  # Move window to dwm tag

    echo "Moving window $window_id_2 to dwm tag 9..."
    xdotool windowmap "$window_id_2"  # Ensure the window is mapped
    xdotool windowactivate "$window_id_2"  # Activate the window before moving
    sleep 0.1  # Wait just a bit after activation for consistency
    xdotool windowfocus "$window_id_2"  # Focus the window again
    xdotool key "Alt+Shift+9"  # Move window to dwm tag
else
    echo "Failed to find both Brave windows for dwm tag 9. Skipping move."
fi

# Launch VLC and move it to dwm tag 8
vlc --loop --random $HOME/Desktop/OTHER/songs/ &
sleep 2  # Wait for VLC to launch (adjust as needed)

# Get the window ID of the VLC process
vlc_window_id=$(xdotool search --onlyvisible --class "vlc" | head -n 1)

# Ensure that the window ID is found before moving it
if [ -n "$vlc_window_id" ]; then
    echo "Moving VLC window $vlc_window_id to dwm tag 8..."
    xdotool windowmap "$vlc_window_id"  # Ensure the window is mapped
    xdotool windowactivate "$vlc_window_id"  # Activate the window before moving
    sleep 0.1  # Wait just a bit after activation for consistency
    xdotool windowfocus "$vlc_window_id"  # Focus the window again
    xdotool key "Alt+Shift+8"  # Move window to dwm tag 8
else
    echo "Failed to find window ID for VLC. Skipping move."
fi

echo "All Brave windows launched and moved to their corresponding dwm tags, VLC moved to tag 8."
