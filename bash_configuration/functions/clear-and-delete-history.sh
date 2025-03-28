clear_and_delete_history() {
    set +o history               
    clear                        
    local history_size=$(history | wc -l)

    if [ "$history_size" -ge 50 ]; then
         cat /dev/null > $XDG_STATE_HOME/bash/bash_history
    fi
   
    if [ "$(history | wc -l)" -gt 0 ]; then
          history -d $(history | tail -n 1 | awk '{print $1}') 
    fi    

    set -o history   
}
