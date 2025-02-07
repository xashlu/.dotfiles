tmux_kill_session() {
  session_name=$(tmux ls | cut -d: -f1 | fzf --prompt="Select a tmux session to kill: ")

  if [ -n "$session_name" ]; then
    tmux kill-session -t "$session_name"
  else
    echo "No session selected. Aborting."
  fi
}

tk() { tmux_kill_session; }
export -f tk
