edit_current_command() {
    temp_file=$(mktemp)

    echo "$READLINE_LINE" > "$temp_file"

    nvim "$temp_file"

    READLINE_LINE=$(<"$temp_file")

    rm -f "$temp_file"

    eval "$READLINE_LINE"
}
