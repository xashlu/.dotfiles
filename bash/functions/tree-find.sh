tree_find() {
    local DIR="${1:-.}"
    (tree "$DIR"; echo ""; find "$DIR" -exec file {} \;) | nvim -
}
