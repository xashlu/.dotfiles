#!/bin/bash

# Default values
DEFAULT_A="$HOME/.dotfiles"  # Source bare Git repository
DEFAULT_B="$HOME/Desktop/DOTFILES"  # Default destination directory
DEFAULT_C=$(mktemp -d)  # Temporary directory for extraction

# Accept command-line argument for destination directory or use default
B="${1:-$DEFAULT_B}"  # Destination directory from the first argument or default
C="$DEFAULT_C"        # Temporary directory

# Show the paths being used
echo "Source Git repository: $DEFAULT_A"
echo "Temporary directory for extraction: $C"
echo "Target directory: $B"

# Ensure the target directory exists
echo "Creating target directory if it doesn't exist..."
mkdir -p "$B"

# Extract the latest commit hash from git log
LATEST_COMMIT=$(git --git-dir="$DEFAULT_A" log --oneline | head -n 1 | awk '{print $1}')

# Check if we got a valid commit hash
if [[ -z "$LATEST_COMMIT" ]]; then
    echo "Error: Could not extract the commit hash from git log."
    exit 1
fi

echo "Latest commit hash is: $LATEST_COMMIT"

# Archive and extract the latest commit into the temporary directory $C
echo "Archiving commit $LATEST_COMMIT from the repository..."
git --git-dir="$DEFAULT_A" archive --format=tar "$LATEST_COMMIT" | tar -xf - -C "$C"

# Synchronize the files from $C to the target directory $B
echo "Synchronizing the target directory $B with the extracted files from $C..."
rsync -av --delete --exclude=".git" "$C/" "$B/"

# Clean up the temporary directory after synchronization
rm -rf "$C"

echo "Synchronization complete. Files from commit $LATEST_COMMIT have been synchronized to $B."
