export PATH="$HOME/.local/bin:/usr/bin:/usr/local/texlive/2024/bin/x86_64-linux:$GOPATH/bin:$PATH"

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"

export HISTFILE="$XDG_STATE_HOME/bash/bash_history"

export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
[ ! -d "$GNUPGHOME" ] && mkdir -p "$GNUPGHOME" && chmod 700 "$GNUPGHOME"

export GOPATH="$XDG_DATA_HOME/go"
export PATH="$GOPATH/bin:$PATH"

export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='wezterm'
export BROWSER='brave'

export MANPAGER='nvim +Man!'
export MANWIDTH=120
export FZF_DEFAULT_OPTS="--bind=ctrl-j:down,ctrl-k:up"

export GTK_THEME=Adwaita:dark

if [ -f "$XDG_CONFIG_HOME/bash/.bashrc" ]; then
    source "$XDG_CONFIG_HOME/bash/.bashrc"
fi
