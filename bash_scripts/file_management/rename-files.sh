#!/bin/bash

# Purpose: Rename files in current directory by replacing substring in their names.
# Usage:
#   ./rename-files.sh <substring_to_replace> <replacement_substring>
#   ./rename-files.sh -a|--all <substring_to_replace> <replacement_substring>
#
# Example:
#   ./rename-files.sh old new              # replace only first occurrence
#   ./rename-files.sh -a old new           # replace all occurrences

rename_files() {
    local replace_all=false
    local args=("$@")

    # Parse optional -a or --all flag
    if [[ "${args[0]}" == "-a" || "${args[0]}" == "--all" ]]; then
        replace_all=true
        # Shift arguments: remove flag, so $1 = to_replace, $2 = replacement
        args=("${args[@]:1}")
    fi

    if [[ ${#args[@]} -ne 2 ]]; then
        echo "Usage: $0 [-a|--all] <substring_to_replace> <replacement_substring>"
        echo "Example:"
        echo "  $0 old new            # replace first occurrence"
        echo "  $0 -a old new         # replace all occurrences"
        exit 1
    fi

    local to_replace="${args[0]}"
    local replacement="${args[1]}"

    # Loop through all *files* in current directory only
    for file in *; do
        # Skip if it's not a regular file
        [[ -f "$file" ]] || continue

        # Skip if file doesn't contain the substring
        [[ "$file" == *"$to_replace"* ]] || continue

        # Choose replacement type based on flag
        if [[ "$replace_all" == true ]]; then
            new_name="${file//$to_replace/$replacement}"
        else
            new_name="${file/$to_replace/$replacement}"
        fi

        # Rename the file
        mv -- "$file" "$new_name"

        # Print the renaming action
        echo "Renamed '$file' to '$new_name'"
    done
}

# Run the function with passed arguments
rename_files "$@"
