#!/bin/bash

function pacman_executable_details() {
    local executable_path
    executable_path=$(which "$1" 2>/dev/null || command -v "$1" 2>/dev/null)

    if [[ -n "$executable_path" ]]; then
        echo "Executable Path: $executable_path"

        local package_name
        package_name=$(pacman -Qo "$executable_path" 2>&1)

        if [[ "$package_name" == *"No package owns"* ]]; then
            echo "No package owns $executable_path. This file is not part of any installed package."
        else
            local pkg_name
            pkg_name=$(echo "$package_name" | awk '{print $5}')
            pacman -Qi "$pkg_name"
        fi
    else
        echo "Executable not found."
    fi
}

# Check if an argument is passed to the script
if [[ -z "$1" ]]; then
    echo "Usage: $0 <executable_name>"
    exit 1
fi

# Call the function with the provided argument
pacman_executable_details "$1"
