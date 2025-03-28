#!/bin/bash

# Description: This script kills all tmux servers, Brave browser processes, VLC media player processes,
#              Zathura document viewer processes, and LibreOffice processes, as well as WezTerm processes.

# Kill all tmux servers
echo "Killing all tmux servers..."
tmux kill-server 2>/dev/null && echo "All tmux servers killed." || echo "No tmux server running."

# Kill Brave browser processes
echo "Checking for Brave browser processes..."
brave_pids=$(pgrep -f brave)
if [[ -z "$brave_pids" ]]; then
    echo "No Brave processes found."
else
    echo "Killing Brave processes: $brave_pids"
    for pid in $brave_pids; do
        kill -9 "$pid" && echo "Killed Brave process $pid"
    done
fi

# Kill WezTerm processes
echo "Checking for WezTerm processes..."
pkill wezterm-gui && echo "Killed all WezTerm processes." || echo "No WezTerm processes found."

# Kill VLC processes
echo "Checking for VLC processes..."
vlc_pids=$(pgrep -f vlc)
if [[ -z "$vlc_pids" ]]; then
    echo "No VLC processes found."
else
    echo "Killing VLC processes: $vlc_pids"
    for pid in $vlc_pids; do
        kill -9 "$pid" && echo "Killed VLC process $pid"
    done
fi

# Kill Zathura processes
echo "Checking for Zathura processes..."
zathura_pids=$(pgrep -f zathura)
if [[ -z "$zathura_pids" ]]; then
    echo "No Zathura processes found."
else
    echo "Killing Zathura processes: $zathura_pids"
    for pid in $zathura_pids; do
        kill -9 "$pid" && echo "Killed Zathura process $pid"
    done
fi

# Kill LibreOffice processes
echo "Checking for LibreOffice processes..."
libreoffice_pids=$(pgrep -f libreoffice)
if [[ -z "$libreoffice_pids" ]]; then
    echo "No LibreOffice processes found."
else
    echo "Killing LibreOffice processes: $libreoffice_pids"
    for pid in $libreoffice_pids; do
        kill -9 "$pid" && echo "Killed LibreOffice process $pid"
    done
fi

echo "System reset completed!"
