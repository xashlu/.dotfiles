#!/bin/bash

# Get all directories in the current directory
directories=($(find . -maxdepth 1 -type d -printf "%f\n" | grep -v '^\.$'))

# Initialize an array to store numeric directory names
declare -A numeric_dirs

# Populate the numeric_dirs array with existing numeric directories
for dir in "${directories[@]}"; do
    if [[ "$dir" =~ ^[0-9]+$ ]]; then
        numeric_dirs["$dir"]=1
    fi
done

# Find the next available numeric name
next_number=0
while [[ -n "${numeric_dirs[$next_number]}" ]]; do
    ((next_number++))
done

# Rename non-numeric directories to successive numeric names
for dir in "${directories[@]}"; do
    if ! [[ "$dir" =~ ^[0-9]+$ ]]; then
        new_name="$next_number"
        echo "Renaming '$dir' to '$new_name/'"
        mv "$dir" "$new_name"
        numeric_dirs["$new_name"]=1
        ((next_number++))
        while [[ -n "${numeric_dirs[$next_number]}" ]]; do
            ((next_number++))
        done
    fi
done
