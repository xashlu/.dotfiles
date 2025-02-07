#!/bin/bash
# Define the path to nvim shada files
nvim_shada_dir="$HOME/.local/state/nvim/shada"

# Clean the nvim shada files before starting the process
echo "Cleaning nvim shada files in $nvim_shada_dir..."
rm -rf "$nvim_shada_dir"/*
# Base directory
base_dir="$HOME/Desktop"

# Path to allowed directories text file
allowed_dirs_file="$HOME/.local/bin/allowed-dirs.txt"

# Initialize arrays
skip_list=()
dont_skip=()  

# Check if the allowed-dirs.txt file exists
if [[ ! -f "$allowed_dirs_file" ]]; then
    echo "Error: $allowed_dirs_file does not exist!"
    exit 1
fi

# Populate the dont_skip array with directories listed in allowed-dirs.txt
while IFS= read -r dir_name; do
    if [[ -n "$dir_name" ]]; then
        dont_skip+=("$dir_name")
    fi
done < "$allowed_dirs_file"

# Define tag mappings (mapping session names to dwm tags)
declare -A tag_mapping=(
    ["XASHLU"]=1
    ["DOCUMENTATIONS"]=2
)

# Function to check if a directory should be skipped
should_skip() {
    local dir_name="$1"
    # Skip if in dont_skip list
    if [[ " ${dont_skip[@]} " =~ " ${dir_name} " ]]; then
        return 1 # Don't skip
    fi
    return 0 # Skip
}

# Array to store session names
sessions=()

# Process directories
for dir in "$base_dir"/*; do
    if [[ -d "$dir" ]]; then
        dir_name=$(basename "$dir")

        # Skip numeric directories
        if [[ "$dir_name" =~ ^[0-9]+$ ]]; then
            echo "Skipping numeric directory: $dir_name"
            continue
        fi

        # Skip directories not in the allowed list (based on the text file)
        if should_skip "$dir_name"; then
            echo "Skipping directory not in allowed list: $dir_name"
            continue
        fi

        echo "Processing directory: $dir_name"
        tmux new-session -d -s "$dir_name" -n "main" "bash --login -c 'cd \"$dir\" && nvim .'"
        sessions+=("$dir_name")

        # Add windows for subdirectories
        window_index=1
        for subdir in "$dir"/*; do
            if [[ -d "$subdir" ]]; then
                subdir_name=$(basename "$subdir")

                # Skip numeric subdirectories
                if [[ "$subdir_name" =~ ^[0-9]+$ ]]; then
                    echo "Skipping numeric subdirectory: $subdir_name"
                    continue
                fi

                echo "Creating tmux window for: $subdir_name in session $dir_name"
                tmux new-window -t "$dir_name:$window_index" -n "$subdir_name" "bash --login -c 'cd \"$subdir\" && nvim .'"
                ((window_index++))
            fi
        done
    fi
done

# Print the allowed directories (dont_skip) and processed sessions
echo "Allowed directories: ${dont_skip[*]}"
echo "Processed sessions: ${sessions[*]}"

# Launch WezTerm and attach tmux sessions based on tag mappings
for session_name in "${!tag_mapping[@]}"; do
    tag="${tag_mapping[$session_name]}"

    # Launch WezTerm for the session (in the background) and capture the process PID
    echo "Launching WezTerm for session $session_name (dwm tag $tag)..."
    wezterm start -- bash -c "tmux attach-session -t \"$session_name\" && exit" &

    # Capture the PID of the last launched process (WezTerm)
    wezterm_pid=$!

    # Wait a moment for WezTerm to initialize and create its window
    sleep 2  # Increase wait time to ensure the window is initialized

    # Get the window ID associated with the WezTerm process using xwininfo or xdotool
    window_id=$(xwininfo -root -tree | grep -i "wezterm" | grep -oP '0x[0-9a-f]+')

    # Ensure that the window ID is found before moving it
    if [ -n "$window_id" ]; then
        # Move the WezTerm window to the correct dwm tag
        echo "Moving window $window_id to dwm tag $tag..."
        xdotool windowmap "$window_id"  # Ensure the window is mapped
        xdotool windowactivate "$window_id"  # Activate the window before moving
        sleep 0.1  # Wait just a bit after activation for consistency
        xdotool windowfocus "$window_id"  # Focus the window again
        xdotool key "Alt+Shift+${tag}"  # Move window to dwm tag
    else
        echo "Failed to find window ID for WezTerm window. Skipping move."
    fi

done

echo "All done!"

