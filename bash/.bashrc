[[ $- != *i* ]] && return

CONFIG_DIR="$XDG_CONFIG_HOME/bash"

EXCLUDE_FILES=(
    "$CONFIG_DIR/aliases/docker.sh"
)

is_excluded() {
    local file="$1"
    for excluded in "${EXCLUDE_FILES[@]}"; do
        [[ "$file" == "$excluded" ]] && return 0
    done
    return 1
}

SYMLINK_DIR="$HOME/.local/bin"
SOURCE_DIR="$HOME/.my-scripts"

for script in "$SOURCE_DIR"/*; do
    ln -sf "$script" "$SYMLINK_DIR/$(basename "$script")"
done

for dir in "$CONFIG_DIR/aliases" "$CONFIG_DIR/functions"; do
    [[ -d "$dir" ]] || continue
    for file in "$dir"/*; do
        [[ -f "$file" ]] || continue
        is_excluded "$file" || . "$file"
    done
done

alias lda=load_docker_aliases
alias c=execute_script
alias C='nvim ~/script'
alias Z=executable_details
alias T=tree_find

set -o vi

bind -x '"\C-p": fzf_select_file'
bind -x '"\C-k": ls -Al'
bind '"\C-o": "nvim .\C-m"'
bind '"\C-n": "tk\C-m"'
bind -x '"\C-l": clear_and_delete_history'
bind -x '"\C-x": edit_current_command'

PS1="\[\033[38;5;39m\]\u\[$(tput sgr0)\]\[\033[38;5;45m\]@\[$(tput sgr0)\]\[\033[38;5;51m\]\h\[$(tput sgr0)\] "\
"\[\033[38;5;190m\]➜\[$(tput sgr0)\] "\
"\[\033[38;5;118m\]\w\[$(tput sgr0)\] "\
"\[\033[38;5;214m\]\$(parse_git_branch)\[$(tput sgr0)\]\n"\
"\[\033[48;5;236m\]\[\033[38;5;231m\]❯\[$(tput sgr0)\] \[\033[0m\]"
