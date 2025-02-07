#!/bin/bash

# Retrieve the current volume of VLC using dbus-send
current_volume=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.vlc \
/org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
string:"org.mpris.MediaPlayer2.Player" \
string:"Volume" | grep -o 'double.*' | awk '{print $2}')

# Check if the volume retrieval was successful
if [ -z "$current_volume" ]; then
  echo "Error: Could not retrieve VLC volume."
  exit 1
fi

# Print current volume
echo "Current VLC volume: $current_volume"

# Increase volume by 5% (0.05)
new_volume=$(echo "$current_volume + 0.05" | bc)

# Print new volume before applying it
echo "New VLC volume after 5% increase: $new_volume"

# Check if the new volume exceeds 100% (1.0)
if (( $(echo "$new_volume > 1.0" | bc -l) )); then
  # If volume exceeds 100%, set it to 100%
  new_volume=1.0
  echo "VLC volume exceeded 100%, setting it to 1.0 (100%)"
fi

# Set the new volume back to VLC
dbus-send --print-reply --dest=org.mpris.MediaPlayer2.vlc \
/org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set \
string:"org.mpris.MediaPlayer2.Player" \
string:"Volume" \
variant:double:$new_volume

# Print final volume
echo "VLC volume set to $new_volume."
