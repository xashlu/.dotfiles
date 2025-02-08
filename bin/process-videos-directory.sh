#!/bin/bash

# Base directory (directory to process)
base_dir="$HOME/Desktop/OTHER/videos"

# Function to download files from URLs in the .txt file
download_files() {
    # Traverse all subdirectories of the base directory (A, B, C, etc.)
    for subdir in "$base_dir"/*/; do
        if [ -d "$subdir" ]; then
            subdirname=$(basename "$subdir")
            txt_file="${subdir}${subdirname}.txt"

            # Check if the subdirectory-name.txt exists
            if [ -f "$txt_file" ]; then
                random_dir="${subdir}random"
                mkdir -p "$random_dir"  # Ensure the 'random' directory exists
                
                # Track if all downloads were successful
                all_downloads_successful=true

                # Read each line (URL) from the subdirectory-name.txt file
                while IFS= read -r url; do
                    if [[ "$url" =~ ^http[s]?:// ]]; then  # Check if the line is a valid URL
                        file_name=$(basename "$url").mp4
                        
                        echo "Downloading from $url into $random_dir/$file_name..."

                        # Use yt-dlp for downloading the video (no extraction or validation)
                        if yt-dlp -o "${random_dir}/${file_name}" "$url"; then
                            echo "Successfully downloaded: $url"
                        else
                            echo "Failed to download: $url"
                            all_downloads_successful=false
                        fi
                    fi
                done < "$txt_file"

                if [ "$all_downloads_successful" = true ]; then
                    echo "All downloads were successful. Clearing $txt_file..."
                    > "$txt_file"
                else
                    echo "Some downloads failed. Keeping $txt_file."
                fi
            fi
        fi
    done
}

# Function to process the downloaded files (move them into proper directories and convert videos)
process_files() {
    # Function to generate the next sequential filename based on existing files
    generate_next_filename() {
        local dir=$1
        local base_name=$2
        local ext=$3
        local index=0

        while [ -e "${dir}/${base_name}-${index}.${ext}" ]; do
            index=$((index + 1))
        done
        echo "${dir}/${base_name}-${index}.${ext}"
    }

    # Traverse the 'parent_dir' for each subdirectory
    for subdir in "$base_dir"/*; do
        if [ -d "$subdir" ]; then
            # Set directory-specific variables
            random_dir="$subdir/random"
            gif_dir="$subdir/gif"
            mp4_dir="$subdir/mp4"

            subdir_name=$(basename "$subdir")
            subdir_initial=$(echo "$subdir_name" | cut -c1)

            mkdir -p "$random_dir" "$gif_dir" "$mp4_dir"

            touch "$subdir/$subdir_name.txt"
            touch "$subdir/${subdir_name}-index.txt"

            # Move non-.txt files into the 'random' directory
            for file in "$subdir"/*; do
                if [ -f "$file" ] && [[ "$file" != *".txt" ]]; then
                    mv "$file" "$random_dir"
                    echo "Moved $file to $random_dir"
                fi
            done

            # Flag to track if all files were processed successfully
            all_processed=true

            # Traverse the 'random' directory for files to process
            for random_file in "$random_dir"/*; do
                if [ -f "$random_file" ]; then
                    file_extension="${random_file##*.}"

                    if [[ "$file_extension" == "gif" ]]; then
                        # Generate sequential filename for gif
                        gif_new_file=$(generate_next_filename "$gif_dir" "$subdir_initial" "gif")
                        mv "$random_file" "$gif_new_file"
                        echo "Moved $random_file to $gif_new_file"
                    else
                        # Process as a video file (e.g., webm, avi, mkv, etc.)
                        mp4_new_file=$(generate_next_filename "$mp4_dir" "$subdir_initial" "mp4")
                        echo "Converting $random_file (Video file) to $mp4_new_file using ffmpeg..."

                        ffmpeg -i "$random_file" -c:v libx264 -crf 23 -preset fast "$mp4_new_file"

                        if [ $? -eq 0 ]; then
                            echo "Successfully converted $random_file to $mp4_new_file"
                        else
                            echo "Error converting $random_file."
                            all_processed=false
                        fi
                    fi
                fi
            done

            # If all files were processed successfully, clean the 'random' directory
            if $all_processed; then
                echo "All files processed successfully in $subdir. Cleaning the random directory."
                if [ "$(ls -A "$random_dir" 2>/dev/null)" ]; then
                    rm -rf "$random_dir"/*
                    echo "Contents of the random directory have been removed."
                else
                    echo "No files to remove in the random directory."
                fi
            else
                echo "Some files were not processed correctly in $subdir. Skipping cleanup of the random directory."
            fi
        fi
    done
}

# Call the functions
download_files
process_files

echo "Download and processing completed."
