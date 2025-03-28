# Ensure this is only executed in interactive shells
[[ $- != *i* ]] && return

# Aliases
alias lda=load_docker_aliases
alias c='execute-bash-script'
alias C='nvim ~/script'
alias Z='pacman-executable-details'

# Set vi mode
set -o vi

# Bash keybindings
bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'
bind '"\t": menu-complete'
bind 'set completion-ignore-case on'

bind -x '"\C-p": source fuzzy-dir-navigator'
bind '"\C-n": "source tmux-kill-session\C-m"'
bind -x '"\C-x": edit_current_command'
bind -x '"\C-l": clear_and_delete_history'
bind '"\C-o": "nvim .\C-m"'
bind -x '"\C-k": ls -Al'

# Custom prompt
PS1="\[\033[38;5;39m\]\u\[$(tput sgr0)\]\[\033[38;5;45m\]@\[$(tput sgr0)\]\[\033[38;5;51m\]\h\[$(tput sgr0)\] "\
"\[\033[38;5;190m\]➜\[$(tput sgr0)\] "\
"\[\033[38;5;118m\]\w\[$(tput sgr0)\] "\
"\[\033[38;5;214m\]\$(parse_git_branch)\[$(tput sgr0)\]\n"\
"\[\033[48;5;236m\]\[\033[38;5;231m\]❯\[$(tput sgr0)\] \[\033[0m\]"
