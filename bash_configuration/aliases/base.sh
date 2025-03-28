alias l='lsblk'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -iv'
alias rr="rm -irf"
alias rrr='function _rr() { sudo find "$1" -type f -exec shred -u -n 3 {} \; && sudo rm -rf "$1"; }; _rr'
