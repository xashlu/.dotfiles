#!/bin/bash

# input file example:
# youtube_url0 start_second end_second filename0
# youtube_url1 start_second end_second filename1

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file with list of video details>"
    exit 1
fi

input_file="$1"

convert_to_seconds() {
    local time_str="$1"
    if [[ "$time_str" == *:* ]]; then
        IFS=':' read -ra time_parts <<< "$time_str"
        case ${#time_parts[@]} in
            2)
                # MM:SS format - force base 10 to handle leading zeros
                min=$((10#${time_parts[0]}))
                sec=$((10#${time_parts[1]}))
                echo $(( min * 60 + sec )) ;;
            3)
                # HH:MM:SS format
                hr=$((10#${time_parts[0]}))
                min=$((10#${time_parts[1]}))
                sec=$((10#${time_parts[2]}))
                echo $(( hr * 3600 + min * 60 + sec )) ;;
            *)
                echo "Invalid time format: $time_str" >&2
                exit 1 ;;
        esac
    else
        # Already in seconds
        echo $((10#$time_str))
    fi
}

process_line() {
    local youtube_url="$1"
    local start_time="$2"
    local end_time="$3"
    local output_name="$4"
    
    echo "Processing: $output_name"
    
    # Convert times
    local start=$(convert_to_seconds "$start_time")
    local end=$(convert_to_seconds "$end_time")
    
    # Validate times
    if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]]; then
        echo "Invalid time values: start=$start, end=$end" >&2
        return 1
    fi
    
    if [ "$start" -ge "$end" ]; then
        echo "Start time must be before end time" >&2
        return 1
    fi
    
    local duration=$((end - start))
    local temp_file="temp_${output_name}_$$.opus"  # Unique temp file using PID

    # Download full audio
    if ! yt-dlp --quiet --extract-audio --audio-format opus -o "$temp_file" "$youtube_url"; then
        echo "Error downloading $output_name" >&2
        rm -f "$temp_file"
        return 1
    fi

    # Trim audio
    if ! ffmpeg -hide_banner -loglevel error -ss "$start" -i "$temp_file" -t "$duration" -c copy "${output_name}.opus"; then
        echo "Error trimming $output_name" >&2
        rm -f "$temp_file" "${output_name}.opus"
        return 1
    fi

    rm -f "$temp_file"
    echo "Completed: $output_name.opus"
}

# Main execution
while IFS=" " read -r youtube_url start_time end_time output_name; do
    [[ "$youtube_url" =~ ^#|^$ ]] && continue
    process_line "$youtube_url" "$start_time" "$end_time" "$output_name" &
done < <(grep -vE '^#|^$' "$input_file")

wait
echo "All processes completed."
