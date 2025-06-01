#!/bin/bash

desktop="$HOME/Desktop"
alias_script="$HOME/.bash-scripts/utilities/update-alias-map.sh"
alias_map="$HOME/Desktop/.alias_map"

# Ensure initial alias map exists
"$alias_script"

# Monitor Desktop for directory create/delete events
inotifywait -m -e create -e delete "$desktop" | while read -r path action file; do
    full_path="$path$file"
    
    # Only trigger if the event involves a directory
    if [ "$action" = "CREATE" ] && [ -d "$full_path" ]; then
        echo "Directory created: $full_path. Updating alias map..."
        "$alias_script"
    elif [ "$action" = "DELETE" ] && [ ! -d "$full_path" ]; then
        echo "Directory deleted: $full_path. Updating alias map..."
        "$alias_script"
    fi
done
