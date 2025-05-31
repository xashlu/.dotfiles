#!/bin/bash

# Target output file
output_file="$HOME/output.txt"

# Create directory structure if needed
mkdir -p "$(dirname "$output_file")" || {
    echo "Error: Failed to create directory structure" >&2
    exit 1
}

# Clear existing file content
> "$output_file" || {
    echo "Error: Failed to clear output file" >&2
    exit 1
}

# Check if pacman-executable-details is available
if ! command -v pacman-executable-details &> /dev/null; then
    echo "Error: pacman-executable-details command not found." >&2
    exit 1
fi

# Hardcoded array of executables (can be modified or left empty)
default_executables=(
    ssh
    ssh-add
    ssh-agent
    ssh-copy-id
    sshd
    ssh-keygen
    ssh-keyscan
)

# Decide which executables to process
if [[ $# -gt 0 ]]; then
    executables=("$@")
    echo "Processing command-line arguments: ${#executables[@]} executables"
else
    executables=("${default_executables[@]}")
    echo "Processing hardcoded list: ${#executables[@]} executables"
fi

# Counter for successful processing
success_count=0

# Process each executable
for exe in "${executables[@]}"; do
    echo -n "Processing $exe... "
    
    # Get package details
    output=$(pacman-executable-details "$exe" 2>/dev/null)
    
    # Skip if executable not found
    if [[ -z "$output" ]]; then
        echo "ERROR: Not found in pacman database" >&2
        continue
    fi
    
    # Extract version and package name
    version=$(awk '/^Version/ {print $3}' <<< "$output")
    pkgname=$(awk '/^Name/ {print $3}' <<< "$output")
    
    # Skip if required fields missing
    if [[ -z "$version" || -z "$pkgname" ]]; then
        echo "ERROR: Couldn't parse details" >&2
        continue
    fi
    
    # Format the output
    formatted="${exe}-${version}-${pkgname}"
    
    # Write to file
    if echo "$formatted" >> "$output_file"; then
        echo "$formatted"
        ((success_count++))
    else
        echo "ERROR: Failed to write to file" >&2
    fi
done

echo "========================================"
echo "Successfully processed: $success_count/${#executables[@]} executables"
echo "Output written to: $output_file"

# Show final file content
echo -e "\nFile content preview:"
cat "$output_file"
