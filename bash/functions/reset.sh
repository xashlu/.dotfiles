function reset() {
    tmux kill-server
    
    brave_pids=$(pgrep -f brave)
    if [[ -z "$brave_pids" ]]; then
        echo "No Brave processes found."
    else
        echo "Killing Brave processes: $brave_pids"
        for pid in $brave_pids; do
            kill -9 $pid && echo "Killed process $pid"
        done
    fi

    pkill wezterm-gui
}
