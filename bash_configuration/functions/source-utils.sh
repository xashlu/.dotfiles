# Define CONFIG_DIR if not already defined
export CONFIG_DIR="$XDG_CONFIG_HOME/bash"

# List of files to exclude from sourcing
EXCLUDE_FILES=(
    "$CONFIG_DIR/aliases/docker.sh"
)

# Function to check if a file is excluded
is_excluded() {
    local file="$1"
    for excluded in "${EXCLUDE_FILES[@]}"; do
        [[ "$file" == "$excluded" ]] && return 0
    done
    return 1
}

# Function to recursively source files in a directory
source_directory() {
    local dir="$1"
    # Skip if the directory does not exist
    [[ -d "$dir" ]] || return

    # Iterate over all items in the directory
    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            # If the item is a directory, recurse into it
            source_directory "$item"
        elif [[ -f "$item" ]]; then
            # If the item is a file, check if it's excluded and source it if not
            is_excluded "$item" || . "$item"
        fi
    done
}

# Main function to source all relevant directories
source_all_directories() {
    local config_dirs=("$CONFIG_DIR/aliases" "$CONFIG_DIR/functions" "$CONFIG_DIR/personal")

    for dir in "${config_dirs[@]}"; do
        source_directory "$dir"
    done
}
