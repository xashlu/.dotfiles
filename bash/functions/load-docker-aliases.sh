load_docker_aliases() {
    local docker_aliases="$CONFIG_DIR/aliases/docker.sh"
    if [ -f "$docker_aliases" ]; then
        . "$docker_aliases"
        echo "Docker aliases loaded."
    else
        echo "No docker aliases found."
    fi
}
