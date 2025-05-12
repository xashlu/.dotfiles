#!/bin/bash
set -euo pipefail

# Input buffer file
BUFFER="$HOME/input.txt"
TMP="$(mktemp)"

if [[ ! -f "$BUFFER" ]]; then
  echo "Error: Buffer file not found at $BUFFER" >&2
  exit 1
fi

# Read all lines
mapfile -t LINES < "$BUFFER"

# Check if the buffer contains any "✘: " markers
contains_markers=false
for line in "${LINES[@]}"; do
  if [[ "$line" =~ ^✘:\ (.+)$ ]]; then
    contains_markers=true
    break
  fi
done

if ! $contains_markers; then
  # Parse PATH{…} blocks
  declare -a PATHS
  collecting=false
  current_dir=""

  for line in "${LINES[@]}"; do
    # start of block, e.g. $HOME or $HOME/A{
    if [[ "$line" =~ ^([^\{]+)\{$ ]]; then
      # expand environment variables in directory
      raw_dir="${BASH_REMATCH[1]}"
      current_dir="$(eval echo "$raw_dir")"
      collecting=true
      continue
    fi

    # end of block
    if [[ "$line" == "}" ]]; then
      collecting=false
      current_dir=""
      continue
    fi

    # inside a block: it's a filename
    if $collecting && [[ -n "$line" ]]; then
      PATHS+=( "$current_dir/$line" )
    fi
  done

  if (( ${#PATHS[@]} == 0 )); then
    echo "Error: No paths found in $BUFFER" >&2
    exit 1
  fi

  # Create each path if it doesn't exist
  for p in "${PATHS[@]}"; do
    dir="$(dirname "$p")"
    mkdir -p "$dir"
    touch "$p"
  done

  # Overwrite the buffer file with ✘: lines
  {
    for p in "${PATHS[@]}"; do
      echo "✘: $p"
    done
  } > "$TMP"

  mv "$TMP" "$BUFFER"
  echo "Success: Created ${#PATHS[@]} files and updated buffer with ✘: entries."
else
  # Gather all ✘: markers
  declare -a paths
  declare -A ranges
  current=""
  for ((i=0; i<${#LINES[@]}; i++)); do
    if [[ "${LINES[i]}" =~ ^✘:\ (.+)$ ]]; then
      # close previous
      if [[ -n "$current" ]]; then
        ranges["$current"]="$start,$((i-1))"
      fi
      current="${BASH_REMATCH[1]}"
      paths+=("$current")
      start=$((i+1))
    fi
  done
  # last block
  if [[ -n "$current" ]]; then
    ranges["$current"]="$start,$(( ${#LINES[@]} - 1 ))"
  fi

  # Process each path: extract its lines and overwrite the file
  for idx in "${!paths[@]}"; do
    p="${paths[idx]}"
    IFS=, read -r s e <<< "${ranges[$p]}"
    mkdir -p "$(dirname "$p")"
    {
      for ((j=s; j<=e; j++)); do
        printf '%s\n' "${LINES[j]}"
      done
    } > "$p"
    echo "Wrote lines $((s+1))–$((e+1)) into $p"
  done
fi
