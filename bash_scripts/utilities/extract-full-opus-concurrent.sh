#!/bin/bash

# extract-full-opus-concurrent
# Usage: extract-full-opus-concurrent <file_with_urls>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file with URLs>"
    exit 1
fi

input_file="$1"
lockfile=".c-opus.lock"
declare -a jobs=()

cleanup_stale_locks() {
    for f in .c-*.lock; do
        [[ -e "$f" ]] || continue
        base="${f#.}"
        opus="${base%.lock}.opus"
        if [[ ! -f "$opus" ]]; then
            rm -f "$f"
        fi
    done
}
cleanup_stale_locks

# returns both: filename and lockfile path
get_next_filename() {
    (
        flock -x 200
        local index=0
        while [[ -f "c-${index}.opus" || -f ".c-${index}.lock" ]]; do
            ((index++))
        done
        local lockfile=".c-${index}.lock"
        touch "$lockfile"
        echo "c-${index}.opus|$lockfile"
    ) 200>"$lockfile"
}

process_url() {
    local url="$1"
    local output_file="$2"
    local lock_path="$3"
    local temp_file="temp_${output_file}_$$.opus"

    echo "Downloading: $url → $output_file"

    if yt-dlp --quiet --extract-audio --audio-format opus -o "$temp_file" "$url"; then
        mv "$temp_file" "$output_file"
        echo "Saved as: $output_file"
    else
        echo "Download failed: $url" >&2
        rm -f "$temp_file"
    fi

    rm -f "$lock_path"
}

# Main logic
while IFS= read -r url; do
    [[ "$url" =~ ^#|^$ ]] && continue

    out_and_lock=$(get_next_filename)
    output_file="${out_and_lock%%|*}"
    lock_path="${out_and_lock##*|}"

    process_url "$url" "$output_file" "$lock_path" &
    jobs+=($!)
done < "$input_file"

for pid in "${jobs[@]}"; do
    wait "$pid"
done

rm -f .c-opus.lock

echo "All downloads completed."
