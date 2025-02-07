execute_script() {
    if [ -z "$1" ]; then
        echo "Please provide a script name."
        return 1
    fi

    script_name="/tmp/$1.sh"

    mkdir -p "/tmp/.scripts"
    {
        echo "#!/bin/bash"
        cat "$HOME/script"
    } > "$script_name"

    if [ -f "$script_name" ]; then
        chmod +x "$script_name"
        echo "Running script: $script_name"
        "$script_name"
    else
        echo "Failed to create the script."
        return 1
    fi
}
