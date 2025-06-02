#!/bin/bash

# Check if a file path is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 /path/to/your/4444.txt"
    exit 1
fi

input_file="$1"

# Make sure the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: File not found: $input_file"
    exit 1
fi

# Get directory of the input file
input_dir=$(dirname "$input_file")

# Change to input directory
cd "$input_dir" || { echo "Failed to cd to $input_dir"; exit 1; }

# Get current dir name
current_dir_name=$(basename "$PWD")

# Define the file we are working with
local_4444="4444.txt"

# Check if any line starts with [
found_bracket=false
while IFS= read -r line; do
    if [[ $line == \[* ]]; then
        found_bracket=true
        break
    fi
done < "$local_4444"

# If no bracket found, prepend [X], where X = first letter of *-aliases.txt
if ! $found_bracket; then
    alias_file=$(ls *-aliases.txt 2>/dev/null | head -n1)
    if [[ -n "$alias_file" ]]; then
        base_name=${alias_file%-aliases.txt}
        first_letter="${base_name:0:1}"
        # Prepend [first_letter] to the top of the file
        sed -i "1i\\[$first_letter]" "$local_4444"
    fi
fi

# Reset flag and process the file
topic=""
exec 3< "$local_4444"
while IFS= read -u 3 -r line; do
    if [[ -z "$line" ]]; then
        echo "Empty line."
        continue
    fi

    if [[ $line == \[* ]]; then
        topic=$(echo "$line" | tr -d '[' | tr -d ']')
        topic=$(echo "$topic" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/ /-/g')
        mkdir -p "$topic"
        continue
    fi

    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/ /-/g')

    if [[ -n "$topic" ]]; then
        filename="$topic/$topic-$line.txt"
    else
        filename="${current_dir_name}-${line}.txt"
    fi

    full_path="$PWD/$filename"

    if [[ ! -f "$full_path" ]]; then
        echo "creating file: $full_path"
        touch "$full_path"
    else
        echo "File already exists: $full_path"
    fi
done
exec 3<&-

# Clear 4444.txt after processing
> "$local_4444"
