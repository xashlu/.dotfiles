#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 [-s size_in_mb] [-d directory] [-f] [-D] [-S] [input_file] [output_directory]"
    echo "  -s size_in_mb : Maximum file size in megabytes to include (default: no limit)"
    echo "  -d directory  : Directory to search (default: current directory)"
    echo "  -f            : Count all files (current dir + subdirs)"
    echo "  -D            : Count all directories (current dir + subdirs)"
    echo "  -S            : Split files into zero-byte and non-zero-byte categories"
    echo "  input_file    : (Optional) File containing null-delimited file paths"
    echo "  output_directory : (Optional) Directory to save output files (default: script-name-output)"
    exit 1
}

# Check if no arguments are provided
if [ $# -eq 0 ]; then
    usage
fi

# Default values
directory="."
input_file=""
min_size=0
count_files=0
count_dirs=0
split_mode=0

# Extract the script name without extension
script_name=$(basename "$0" .sh)
output_directory="${script_name}-output"

# Prepare directory
mkdir -p "$output_directory"
rm -rf "$output_directory"/*

# Define an array of patterns to exclude
EXCLUDES=(
  "*/.git/*"
  "*.py[cod]"
  "*/__pycache__/*"
  "*.so"
  "*.egg-info/*"
  "*.log"
  "*/.env/*"
  "*/venv/*"
  "*.pyo"
  "*/site-packages/*"
  "*.dist-info/*"
  "*.o"
  "*.a"
  "*.dll"
  "*.exe"
  "*.gcda"
  "*.gcno"
  "*.dSYM/*"
  "*.idb"
  "*.class"
  "*/target/*"
  "*/build/*"
  "*.luac"
  ".DS_Store"
  "Thumbs.db"
  "*.swp"
  "*/.idea/*"
  "*/.vscode/*"
  "*/node_modules/*"
)

# Parse options
while getopts ":s:d:fDS" opt; do
    case "$opt" in
        s)
            min_size="$OPTARG"
            ;;
        d)
            directory="$OPTARG"
            ;;
        f)
            count_files=1
            ;;
        D)
            count_dirs=1
            ;;
        S)
            split_mode=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# If an input file is provided as an argument
if [ $# -ge 1 ]; then
    input_file="$1"
    shift
fi

# If no input file is provided, generate it
if [ -z "$input_file" ]; then
    input_file="${output_directory}/file_list.txt"
    
    # Construct the find command with exclusions
    find_cmd=(find "$directory" -type f)
    
    # Add exclusion patterns to the find command
    for pattern in "${EXCLUDES[@]}"; do
        find_cmd+=(-not -path "$pattern")
    done
    
    # Add size condition if defined
    if [ "$min_size" -gt 0 ]; then
        find_cmd+=(-size -"$((min_size * 1024 * 1024))"c)
    fi
    
    # Add the print0 to make the output null-delimited
    find_cmd+=(-print0)

    # Execute the constructed find command and redirect output to the input file
    "${find_cmd[@]}" | sort -z > "$input_file"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate input file. Please check directory permissions."
        exit 1
    fi
fi

count_files_func() {
    count=$(find "$directory" -type f -print0 | tr -cd '\0' | wc -c)
    echo "Total files in '$directory': $count"
}

count_dirs_func() {
    count=$(find "$directory" -type d -print0 | tr -cd '\0' | wc -c)
    echo "Total directories in '$directory': $count"
}

# Process the input file
if [ "$split_mode" -eq 1 ]; then
    empty_output="${output_directory}/empty_files.txt"
    nonempty_output="${output_directory}/non_empty_files.txt"
    > "$empty_output"
    > "$nonempty_output"

    xargs -0 du -b 2>/dev/null < "$input_file" | awk -v empty_out="$empty_output" -v nonempty_out="$nonempty_output" '{
        if ($1 == 0)
            print $2, $1 >> empty_out;
        else
            print $2, $1 >> nonempty_out;
    }'

    echo "Empty files (0 bytes):"
    cat "$empty_output"
    echo ""
    echo "Non-empty files (>0 bytes):"
    cat "$nonempty_output"
    echo ""

    countEmpty=$(wc -l < "$empty_output")
    countNonEmpty=$(wc -l < "$nonempty_output")
    echo "Processing complete."
    echo "Empty files: $countEmpty"
    echo "Non-empty files: $countNonEmpty"
    echo "Results saved in '$empty_output' and '$nonempty_output'."
else
    output_file="${output_directory}/output.txt"
    > "$output_file"
    xargs -0 du -b 2>/dev/null < "$input_file" | while read -r size filepath; do
         echo "$filepath $size" >> "$output_file"
    done

    echo "Combined output:"
    cat "$output_file"
    countCombined=$(wc -l < "$output_file")
    echo ""
    echo "Processing complete. Total files processed: $countCombined."
    echo "Results saved in '$output_file'."
fi

if [ "$count_files" -eq 1 ]; then
    count_files_func
fi

if [ "$count_dirs" -eq 1 ]; then
    count_dirs_func
fi
