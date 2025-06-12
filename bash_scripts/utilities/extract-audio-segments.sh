#!/bin/bash

# Hardcoded video path
VIDEO_PATH=""

# Verify video file exists
if [ ! -f "$VIDEO_PATH" ]; then
    echo "Error: Local video file not found at $VIDEO_PATH"
    exit 1
fi

# Hardcoded segments (start_time end_time output_name)
declare -a segments=(
)

convert_to_seconds() {
    local time_str="$1"
    if [[ "$time_str" == *:* ]]; then
        IFS=':' read -ra time_parts <<< "$time_str"
        case ${#time_parts[@]} in
            2)
                min=$((10#${time_parts[0]}))
                sec=$((10#${time_parts[1]}))
                echo $(( min * 60 + sec )) ;;
            3)
                hr=$((10#${time_parts[0]}))
                min=$((10#${time_parts[1]}))
                sec=$((10#${time_parts[2]}))
                echo $(( hr * 3600 + min * 60 + sec )) ;;
            *)
                echo "Invalid time format: $time_str" >&2
                exit 1 ;;
        esac
    else
        echo $((10#$time_str))
    fi
}

process_segment() {
    local start_time="$1"
    local end_time="$2"
    local output_name="$3"
    
    echo "Processing: $output_name"
    
    local start=$(convert_to_seconds "$start_time")
    local end=$(convert_to_seconds "$end_time")
    
    if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]]; then
        echo "Invalid time values: start=$start, end=$end" >&2
        return 1
    fi
    
    if [ "$start" -ge "$end" ]; then
        echo "Start time must be before end time" >&2
        return 1
    fi
    
    local duration=$((end - start))
    local output_file="${output_name}.opus"  # Use .opus extension

    # Force stereo output (-ac 2) and Ogg container
    if ! ffmpeg -hide_banner -loglevel error -i "$VIDEO_PATH" \
        -ss "$start" -t "$duration" -vn -c:a libopus -ac 2 -f ogg "$output_file"; then
        echo "Error extracting $output_file" >&2
        rm -f "$output_file"
        return 1
    fi

    echo "Completed: $output_file"
}

# Main execution
for segment in "${segments[@]}"; do
    IFS=' ' read -r start end name <<< "$segment"
    process_segment "$start" "$end" "$name"
done

echo "All segments processed."
