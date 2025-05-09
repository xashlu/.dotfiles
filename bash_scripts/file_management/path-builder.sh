#!/bin/bash

# Define the input file
input_file="$HOME/input.txt"

# Check if input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file $input_file not found."
    exit 1
fi

# Create temporary file
temp_file=$(mktemp)

# Parse input file and create structure
paths=()
current_dir=""
current_files=()

while IFS= read -r line; do
    if [[ $line =~ ^(.*)\{(.*) ]]; then
        # Directory block start
        current_dir="${BASH_REMATCH[1]}"
        current_files=()
        IFS=' ' read -ra filenames <<< "${BASH_REMATCH[2]}"
        for file in "${filenames[@]}"; do
            [[ -n "$file" ]] && current_files+=("$file")
        done
    elif [[ $line == '}' ]]; then
        # Directory block end
        if [[ -n "$current_dir" ]]; then
            for file in "${current_files[@]}"; do
                full_path="$current_dir/$file"
                paths+=("$full_path")
            done
            current_dir=""
            current_files=()
        fi
    elif [[ -n "$current_dir" ]]; then
        # File in current directory
        current_files+=("$line")
    fi
done < "$input_file"

# Create directories and files with safety checks
for file_path in "${paths[@]}"; do
    dir_path=$(dirname "$file_path")
    
    # Check for directory/file conflict
    if [[ -e "$dir_path" && ! -d "$dir_path" ]]; then
        echo "Error: Path $dir_path exists but is not a directory."
        echo "Delete it manually with: rm '$dir_path'"
        exit 1
    fi
    
    # Create directory if needed
    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path" || {
            echo "Error: Failed to create directory $dir_path"
            exit 1
        }
    fi
    
    # Create file if it doesn't exist
    if [[ ! -e "$file_path" ]]; then
        touch "$file_path" || {
            echo "Error: Failed to create file $file_path"
            exit 1
        }
    fi
done

# Rebuild input.txt with 3 newlines after each path
for file_path in "${paths[@]}"; do
    echo "$file_path" >> "$temp_file"
    printf '\n\n\n' >> "$temp_file"  # Add 3 newlines
done

# Replace original file
mv "$temp_file" "$input_file"

echo "Success: File structure created and input.txt updated."
