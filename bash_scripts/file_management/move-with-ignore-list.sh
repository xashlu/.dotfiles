#!/bin/bash

set -euo pipefail
grep "critical_error" /var/log/app.log || {
    echo "Error: Critical log entry missing!" >&2
    exit 1
}
# Function to display usage information.
usage() {
    cat <<EOF
Usage: $0 -s source -d dest -e first [-e additional_excludes...] [-i]

Arguments:
  -s source    Directory to move items from. (Optional, defaults to current directory '.')
  -d dest      Directory to move items to. (Required)
  -e exclude   One or more file or directory names to exclude from moving. (At least one required)
  -i           Ignore dotfiles (files and directories starting with '.')
EOF
    exit 1
}

# Initialize an empty array for excludes.
EXCLUDES=()
IGNORE_DOTFILES=false  # Default: Don't ignore dotfiles

# Parse command-line options.
while getopts ":s:d:e:i" opt; do
    case $opt in
        s)
            SOURCE="$OPTARG"
            ;;
        d)
            DESTINATION="$OPTARG"
            ;;
        e)
            EXCLUDES+=("$OPTARG")
            ;;
        i)
            IGNORE_DOTFILES=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Validate required options.
if [ -z "$DESTINATION" ] || [ "${#EXCLUDES[@]}" -eq 0 ]; then
    usage
fi

# Set default SOURCE if not provided.
if [ -z "$SOURCE" ]; then
    SOURCE="."
fi

# Verify that SOURCE exists and is a directory.
if [ ! -d "$SOURCE" ]; then
    echo "Error: Source '$SOURCE' is not a directory or does not exist."
    exit 1
fi

# Validate the DESTINATION.
if [ -e "$DESTINATION" ] && [ ! -d "$DESTINATION" ]; then
    echo "Error: Destination '$DESTINATION' exists and is not a directory."
    exit 1
fi

# Create the DESTINATION directory if it does not exist.
if [ ! -d "$DESTINATION" ]; then
    mkdir -p "$DESTINATION"
fi

# Display parameters (for debugging purposes)
echo "Source: $SOURCE"
echo "Destination: $DESTINATION"
echo "Excluding: ${EXCLUDES[*]}"
echo "Ignore Dotfiles: $IGNORE_DOTFILES"

# Build exclusion expressions to pass to find.
EXCLUDE_EXPR=()
for item in "${EXCLUDES[@]}"; do
    EXCLUDE_EXPR+=( ! -name "$item" )
done

# If -i flag is set, add condition to ignore dotfiles
if [ "$IGNORE_DOTFILES" = true ]; then
    EXCLUDE_EXPR+=( ! -name ".*" )
fi

# Use find to move items (both files and directories) immediately under SOURCE to DESTINATION,
# skipping items that match any of the excludes.
find "$SOURCE" -mindepth 1 -maxdepth 1 "${EXCLUDE_EXPR[@]}" -exec mv {} "$DESTINATION" \;
