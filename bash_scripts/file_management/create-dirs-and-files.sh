current_dir_name=$(basename "$PWD")
found_bracket=false 
while IFS= read -r line; do
    if [[ $line == \[* ]]; then
        found_bracket=true
        break 
    fi
done < "$PWD/4444.txt"

if $found_bracket; then
    while IFS= read -r line; do
        if [[ ! -n $line ]]; then
            echo "Empty line."
            continue
        fi

        if [[ $line == \[* ]]; then
            topic=$(echo "$line" | tr -d '[' | tr -d ']') 
            topic=$(echo "$topic" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/ /-/g') 
        else
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/ /-/g') 
            mkdir -p "$PWD/$topic" 
            if [[ ! -f "$PWD/$topic/$topic-$line.txt" ]]; then
                echo "creating file: $PWD/$topic/$topic-$line.txt"
                touch "$PWD/$topic/$topic-$line.txt"
            else
                echo "File already exists: $PWD/$topic/$topic-$line.txt"
            fi
        fi
    done < "$PWD/4444.txt"
else
    while IFS= read -r line; do
        if [[ -z $line ]]; then
            echo "Empty line."
            continue
        fi
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/ /-/g') 
        filename="$PWD/${current_dir_name}-$line.txt"
        if [[ ! -f "$filename" ]]; then
            echo "creating file: $filename"
            touch "$filename"
        else
            echo "File already exists: $filename"
        fi
    done < "$PWD/4444.txt"
fi
cat /dev/null > "$PWD/4444.txt"
