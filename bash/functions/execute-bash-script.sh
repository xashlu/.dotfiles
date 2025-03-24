execute_script() {
    # Default script name is "a.sh" if no argument is provided
    local script_name="/tmp/${1:-a}.sh"
    local output_log="/tmp/output_log_$(date +%Y%m%d_%H%M%S).log"

    # Ensure the directory exists (optional, but good practice)
    mkdir -p "/tmp/.scripts"

    # Overwrite the script file each time with a shebang, debugging options, and the content of "$HOME/script"
    echo "Overwriting script: $script_name"
    {
        echo "#!/bin/bash"
        echo "set -uo pipefail"  # Enable strict error handling in the script
        echo "set -x"            # Enable tracing in the script
        cat "$HOME/script"
    } > "$script_name"

    # Check if the script file was successfully created
    if [ -f "$script_name" ]; then
        chmod +x "$script_name"  # Make the script executable
        echo "Running script: $script_name"
        
        # Execute the script and capture ALL output (stdout and stderr)
        "$script_name" > "$output_log" 2>&1

        # Open the output log file in Neovim in the current terminal
        if command -v nvim &>/dev/null; then
            echo "Opening output log in Neovim..."
            nvim "$output_log"
        else
            echo "Neovim is not installed. Please install Neovim to open the output log."
        fi
    else
        echo "Failed to create the script."
        return 1
    fi
}
