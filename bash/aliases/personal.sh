alias dq='/usr/bin/git --git-dir="$HOME//.dotfiles/" --work-tree="$HOME/"'
alias dqq='dq add -u && dq commit -m "reji" && dq push'
alias dqs='dq status'
alias o='cd ~/Desktop/ && nvim .'
alias s='cd ~/Desktop/OTHER/songs && nvim SSSSS.txt'
alias y='extract-audio-from-youtube-video.sh* SSSSS.txt'
alias B='backup-pe-hdd-cu-sdb-partition.sh'
alias I='cd $HOME/Desktop/IMPLEMENTATIONS && nvim .'
alias p='cd $HOME/Desktop/OTHER/photos/'
alias v='cd "$HOME/Desktop/OTHER/videos" && vlc $(find "$PWD" -type f -path "*/mp4/*.mp4" | awk -F/ -vOFS=/ '\''{print $(NF-2), $0}'\'' | sort -k1,1 -t/ -k2,2V | cut -d/ -f2-)'
alias n='nvim'
alias mk='make_dir_cd_dir() { mkdir -p "$1" && cd "$1"; }; make_dir_cd_dir'
alias mK='make_dir_cd_dir() { mkdir -p "$1" && cd "$1" && git init && echo a>a && git add . && git commit -m "1st";
}; make_dir_cd_dir'
alias ro='switch_layout_ro() { setxkbmap ro std && [[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap; }; switch_layout_ro'
alias us='switch_layout_us() { setxkbmap us && [[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap; }; switch_layout_us'
alias z='cat'
alias m='man'
