#!/bin/bash

# Log file
log_file="/tmp/reattach_debug.log"

> "$log_file"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$log_file"
}

# Identify active tmux sockets
sockets=($(find /tmp/tmux-$(id -u) -type s -name "wezterm-*" 2>/dev/null))
log "found ${#sockets[@]} sockets"

# Cleanup unused sockets
for sock in "${sockets[@]}"; do
  if ! lsof "$sock" &>/dev/null; then
    rm -f "$sock"
    log "removed unused socket: $sock"
  fi
done

if [ ${#sockets[@]} -eq 0 ]; then
  echo "no active wezterm tmux sockets found"
  log "no active sockets found"
  exit 1
fi

# Format for fzf
options=()
for sock in "${sockets[@]}"; do
  options+=("$(basename "$sock") $(echo "$sock" | sed 's/.*\///')")
done

# Fuzzy select socket
selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="select socket: ")
log "selected socket: $selected"

# Extract full path
socket_basename=$(echo "$selected" | awk '{print $1}')
socket_path="/tmp/tmux-$(id -u)/$socket_basename"
log "socket path: $socket_path"

if [ ! -S "$socket_path" ]; then
  echo "selected socket does not exist"
  log "socket file not found at $socket_path"
  exit 1
fi

# List sessions
sessions=$(tmux -S "$socket_path" ls 2>/dev/null | cut -d: -f1)
log "found sessions: $sessions"

if [ -z "$sessions" ]; then
  echo "no sessions found in socket $socket_path"
  log "no sessions found in socket $socket_path"
  exit 1
fi

# Fuzzy select session
session_name=$(echo "$sessions" | fzf --prompt="select session to reattach: ")
log "selected session: $session_name"

if [ -z "$session_name" ]; then
  echo "no session selected"
  log "no session name extracted"
  exit 1
fi

# Reattach in current terminal
log "executing: tmux -S \"$socket_path\" attach-session -t \"$session_name\""
exec tmux -S "$socket_path" attach-session -t "$session_name"
