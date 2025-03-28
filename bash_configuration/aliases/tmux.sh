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
    # Get tmux server PID
    tmux_pid=$(pgrep -o tmux)
    
    # Get all child processes of tmux
    child_pids=$(pstree -p $tmux_pid | grep -o "([0-9]\+)" | tr -d "()")
    
    # Calculate total memory usage
    total_mem=$(ps -o rss= -p $tmux_pid $child_pids 2>/dev/null | awk "{sum+=\$1} END {
        bytes = sum * 1024
        if (bytes >= 1073741824) {
            hr = sprintf(\"%.1f GB\", bytes / 1073741824)
        } else if (bytes >= 1048576) {
            hr = sprintf(\"%.1f MB\", bytes / 1048576)
        } else if (bytes >= 1024) {
            hr = sprintf(\"%.1f KB\", bytes / 1024)
        } else {
            hr = sprintf(\"%d B\", bytes)
        }
        printf \"%d bytes (%s)\", bytes, hr
    }")
    
    echo "Total tmux ecosystem RAM usage: $total_mem"
    
    # Show top 5 memory-consuming processes within tmux
    echo -e "\nTop 5 memory-consuming processes in tmux ecosystem:"
    ps -o pid,rss,cmd --sort=-rss -p $tmux_pid $child_pids 2>/dev/null | head -n 6
  fi
'
