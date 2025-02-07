fzf_select_file() {
  while true; do
    local files
    files=$(ls -aF | grep -v '^./$')

    local selection
    local key
    selection=$(echo "$files" | fzf --bind 'tab:accept' --bind "esc:abort" --header 'Press Tab to enter directories,
    Enter to open path, Esc to open current directory in Neovim' --expect tab,enter,esc)

    key=$(echo "$selection" | head -n 1)
    selection=$(echo "$selection" | tail -n 1)

    if [[ "$key" == "esc" ]]; then
      nvim .
      break
    elif [[ -n "$selection" ]]; then
      local selected_cleaned=${selection%/}

      if [[ "$key" == "enter" ]]; then
        if [[ -d "$selected_cleaned" ]]; then
          cd "$selected_cleaned" || return
        elif [[ -f "$selected_cleaned" ]]; then
          echo "$(pwd)/$selected_cleaned"
        fi
        break
      elif [[ "$key" == "tab" ]]; then
        if [[ -d "$selected_cleaned" ]]; then
          cd "$selected_cleaned" || return
        fi
        continue
      fi
    else
      break
    fi
  done
}
