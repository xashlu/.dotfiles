#!/bin/bash
# input file example:
# youtube_url0 start_second end_second filename0
# youtube_url1 start_second end_second filename1

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file with list of video details>"
    exit 1
fi

input_file="$1"

# Ensure the file exists
if [ ! -f "$input_file" ]; then
    echo "File not found: $input_file"
    exit 1
fi

# Function to convert time in "MM:SS" or "HH:MM:SS" format to seconds
convert_to_seconds() {
    local time_str="$1"
    if [[ "$time_str" == *:* ]]; then
        # If the time contains a colon (:) we need to convert it
        IFS=':' read -ra time_parts <<< "$time_str"
        if [ ${#time_parts[@]} -eq 2 ]; then
            # MM:SS format
            minutes=$(echo "${time_parts[0]}" | sed 's/^0*//')  
            seconds=$(echo "${time_parts[1]}" | sed 's/^0*//')  
            echo $((minutes * 60 + seconds))
        elif [ ${#time_parts[@]} -eq 3 ]; then
            # HH:MM:SS format
            hours=$(echo "${time_parts[0]}" | sed 's/^0*//')    
            minutes=$(echo "${time_parts[1]}" | sed 's/^0*//')  
            seconds=$(echo "${time_parts[2]}" | sed 's/^0*//')  
            echo $((hours * 3600 + minutes * 60 + seconds))
        fi
    else
        # If there's no colon, it's already in seconds (strip any leading zeros)
        echo "$(echo "$time_str" | sed 's/^0*//')"
    fi
}

while IFS=" " read -r youtube_url start_time end_time output_name; do
    echo "Processing: $output_name"

    # Convert start and end times to seconds if necessary
    start_time_in_seconds=$(convert_to_seconds "$start_time")
    end_time_in_seconds=$(convert_to_seconds "$end_time")

    # Download and extract only the audio, saving it as .opus
    yt-dlp --extract-audio --audio-format opus --downloader ffmpeg_file \
           --external-downloader-args "ffmpeg:-ss $start_time_in_seconds -to $end_time_in_seconds" \
           --output "$output_name.opus" "$youtube_url"

done < "$input_file"
