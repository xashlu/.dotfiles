alias t='tmux a'
alias tl='tmux list-sessions'

alias ks='echo "Active tmux processes:" && \
           pgrep tmux | xargs -I {} sh -c '\''ps -p {} -o pid,cmd && echo "───"'\'' && \
           echo "Killing all tmux processes..." && \
           pkill tmux'

alias kh='
  if ! pgrep tmux &>/dev/null; then
    echo "No tmux processes found";
  else
    total_mem=$(ps -e --forest -o rss,cmd | grep -A 1000 "tmux" | grep -v "grep" | awk '"'"'{
        sum += $1
    }
    END {
        bytes = sum * 1024
        if (bytes >= 1073741824) {
            hr = sprintf("%.1f GB", bytes / 1073741824)
        } else if (bytes >= 1048576) {
            hr = sprintf("%.1f MB", bytes / 1048576)
        } else if (bytes >= 1024) {
            hr = sprintf("%.1f KB", bytes / 1024)
        } else {
            hr = sprintf("%d B", bytes)
        }
        printf "%d bytes (%s)", bytes, hr
    }'"'"');
    echo "Total tmux ecosystem RAM usage: $total_mem"
  fi
'
