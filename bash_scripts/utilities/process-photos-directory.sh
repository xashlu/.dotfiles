#!/bin/bash

# Define the base directory (hardcoded path)
BASE_DIR="$HOME/Desktop/OTHER/photos"

# Function to move all files to a random directory
move_files_to_random() {
    local subdir_path=$1
    local random_dir="$subdir_path/random"

    echo "Ensuring random directory exists: $random_dir"
    mkdir -p "$random_dir"

    # Move all files (excluding directories and the random folder itself) to the random directory
    for file in "$subdir_path"/*; do
        if [[ -f "$file" ]]; then
            mv "$file" "$random_dir/"
            echo "Moved $(basename "$file") to $random_dir"
        fi
    done
}

# Function to move files from the random directory to the target directories (jpg/png)
move_files_from_random_to_target() {
    local destination_random_dir=$1
    local target_jpg_dir=$2
    local target_png_dir=$3
    local subdir_name=$4

    echo "Processing random files from: $destination_random_dir"

    # Initialize counters for jpg and png
    local jpg_counter=0
    local png_counter=0

    # Loop through the files in the random directory
    for file in "$destination_random_dir"/*; do
        if [[ -f "$file" ]]; then
            local ext="${file##*.}"
            ext="${ext,,}"  # Convert to lowercase

            if [[ "$ext" == "jpeg" || "$ext" == "jpg" ]]; then
                local new_file_name="${subdir_name:0:1}-${jpg_counter}.jpg"
                local target_file="$target_jpg_dir/$new_file_name"

                while [[ -f "$target_file" ]]; do
                    ((jpg_counter++))
                    new_file_name="${subdir_name:0:1}-${jpg_counter}.jpg"
                    target_file="$target_jpg_dir/$new_file_name"
                done

                mv "$file" "$target_file"
                echo "Moved $(basename "$file") to $target_file"
                ((jpg_counter++))
            elif [[ "$ext" == "png" ]]; then
                local new_file_name="${subdir_name:0:1}-${png_counter}.png"
                local target_file="$target_png_dir/$new_file_name"

                while [[ -f "$target_file" ]]; do
                    ((png_counter++))
                    new_file_name="${subdir_name:0:1}-${png_counter}.png"
                    target_file="$target_png_dir/$new_file_name"
                done

                mv "$file" "$target_file"
                echo "Moved $(basename "$file") to $target_file"
                ((png_counter++))
            else
                echo "Skipping unsupported file format: $(basename "$file")"
            fi
        fi
    done
}

# Function to create an empty index file with the subdirectory's name
create_index_file() {
    local subdir_path=$1
    local subdir_name=$2

    # Create the subdirectory-index.txt file with no contents
    local index_file="$subdir_path/$subdir_name-index.txt"
    touch "$index_file"
    echo "Created empty index file: $index_file"
}

# Function to process files and directories in-place within the base directory
process_directory_in_place() {
    local base_dir=$1

    echo "Processing all subdirectories and files in $base_dir"

    # Loop through all directories in the base directory
    for subdir_path in "$base_dir"/*; do
        if [[ -d "$subdir_path" ]]; then
            local subdir_name=$(basename "$subdir_path")

            echo "Processing subdirectory: $subdir_name"

            # Create jpg and png subdirectories if they don't exist
            local jpg_dir="$subdir_path/jpg"
            local png_dir="$subdir_path/png"
            mkdir -p "$jpg_dir" "$png_dir"

            # Ensure a random directory exists and move all files there
            move_files_to_random "$subdir_path"

            # Process the random directory
            local random_dir="$subdir_path/random"
            if [[ -d "$random_dir" ]]; then
                move_files_from_random_to_target "$random_dir" "$jpg_dir" "$png_dir" "$subdir_name"

                rm -rf "$random_dir"/*
                echo "Cleared random directory: $random_dir"
            fi

            # Create the index file with no content
            create_index_file "$subdir_path" "$subdir_name"
        fi
    done
}

# Main function to process the directory in-place
main() {
    if [[ ! -d "$BASE_DIR" ]]; then
        echo "Base directory $BASE_DIR does not exist!"
        exit 1
    fi

    process_directory_in_place "$BASE_DIR"

    echo "Processing completed successfully!"
}

main
