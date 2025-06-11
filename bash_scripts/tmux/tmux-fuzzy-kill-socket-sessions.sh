#!/bin/bash

# Temp file to store output for fzf
TMP=$(mktemp)

# List sockets and their sessions in the desired format
for sock_path in /tmp/tmux-*/*; do
  sock_name=$(basename "$sock_path")
  if tmux -S "$sock_path" ls &>/dev/null; then
    echo "$sock_name" >> "$TMP"
    tmux -S "$sock_path" ls | cut -d: -f1 | sed 's/^/  /' >> "$TMP"
  fi
done

# Run fzf and let user pick an entry
selection=$(cat "$TMP" | fzf --prompt="Select socket to kill all sessions: ")

# Only proceed if the user selected a socket (no indentation)
if [[ "$selection" != "  "* ]]; then
  selected_socket="$selection"
  full_path=$(find /tmp -type s -name "$selected_socket" 2>/dev/null)

  if [[ -n "$full_path" ]]; then
    echo "Killing all sessions in socket: $selected_socket"
    tmux -S "$full_path" ls | cut -d: -f1 | while read -r session; do
      tmux -S "$full_path" kill-session -t "$session"
    done
  else
    echo "Socket path not found."
  fi
else
  echo "You selected a session, not a socket. Please select a socket."
fi

rm -rf "$TMP"
