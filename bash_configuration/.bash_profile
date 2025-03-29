#!/bin/bash

# Enable optional debugging
DEBUG=0

log_debug() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown Time")
    [ "$DEBUG" -eq 1 ] && printf "[DEBUG] [%s] %s\n" "$timestamp" "$1"
}

# XDG Base Directory Specification
declare -A XDG_DIRS=(
    ["XDG_CONFIG_HOME"]="${XDG_CONFIG_HOME:-$HOME/.config}"
    ["XDG_DATA_HOME"]="${XDG_DATA_HOME:-$HOME/.local/share}"
    ["XDG_STATE_HOME"]="${XDG_STATE_HOME:-$HOME/.local/state}"
    ["XDG_CACHE_HOME"]="${XDG_CACHE_HOME:-$HOME/.cache}"
)

# Export XDG variables
for key in "${!XDG_DIRS[@]}"; do
    export "$key"="${XDG_DIRS[$key]}"
    log_debug "Set $key=${XDG_DIRS[$key]}"
done

# Function to create directories with error handling and optional permissions
create_dir() {
    local dir="$1"
    local perm="${2:-755}" # Default permission to 755
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" && chmod "$perm" "$dir" || {
            printf "Warning: Failed to create directory %s with permissions %s\n" "$dir" "$perm"
            return 1
        }
    fi
    log_debug "Created directory: $dir with permissions: $perm"
    return 0
}

# Create necessary directories
create_dir "$XDG_CONFIG_HOME"
create_dir "$XDG_DATA_HOME"
create_dir "$XDG_STATE_HOME"

# PATH Configuration
declare -a PATH_DIRS=(
    "$HOME/.local/bin"
    "/usr/local/texlive/2024/bin/x86_64-linux"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
)

# Add $HOME/.local/bin and its subdirectories to PATH_DIRS
if [[ -d "$HOME/.local/bin" ]]; then
    PATH_DIRS+=("$HOME/.local/bin")
    # Find all subdirectories under $HOME/.local/bin
    while IFS= read -r subdir; do
        PATH_DIRS+=("$subdir")
    done < <(find "$HOME/.local/bin" -mindepth 1 -type d)
fi


# Go configuration
export GOPATH="$XDG_DATA_HOME/go"
PATH_DIRS+=("$GOPATH/bin")

# Anaconda configuration (if installed)
if [ -d "$HOME/anaconda3/bin" ]; then
    PATH_DIRS+=("$HOME/anaconda3/bin")
fi

# Function to deduplicate PATH entries
clean_path() {
    local old_PATH="$1"
    local new_PATH=""
    local dir
    declare -A seen

    IFS=: read -ra path_array <<< "$old_PATH"
    for dir in "${path_array[@]}"; do
        if [ -n "$dir" ] && [ ! "${seen[$dir]:-}" ]; then
            new_PATH="${new_PATH:+$new_PATH:}$dir"
            seen[$dir]=1
        fi
    done
    echo "$new_PATH"
}

# Set and clean PATH
PATH="$(IFS=:; echo "${PATH_DIRS[*]}"):$PATH"
PATH=$(clean_path "$PATH")
export PATH

# Symlink scripts from SOURCE_DIR to SYMLINK_DIR
export SOURCE_DIR="${SOURCE_DIR:-$HOME/.bash-scripts}"
export SYMLINK_DIR="${SYMLINK_DIR:-$HOME/.local/bin}"
create_dir "$SYMLINK_DIR"

create_symlink() {
    local src="$1"
    local dest="$2"
    if [[ ! -f "$src" ]]; then
        printf "Warning: Source file not found: %s\n" "$src"
        return 1
    fi
    # Ensure the parent directory of the symlink exists
    create_dir "$(dirname "$dest")"
    ln -sf "$src" "$dest" || {
        printf "Warning: Failed to create symlink: %s\n" "$dest"
        return 1
    }
    log_debug "Created symlink: $src -> $dest"
}

symlink_all_scripts() {
    if [[ -d "$SOURCE_DIR" ]]; then
        # Find all .sh files in SOURCE_DIR and its subdirectories
        while IFS= read -r script; do
            # Get the relative path of the script within SOURCE_DIR
            relative_path="${script#$SOURCE_DIR/}"
            # Create the corresponding symlink in SYMLINK_DIR
            symlink_path="$SYMLINK_DIR/${relative_path%.sh}"
            create_symlink "$script" "$symlink_path"
        done < <(find "$SOURCE_DIR" -type f -name "*.sh")
    else
        printf "Warning: Source directory not found: %s\n" "$SOURCE_DIR"
    fi
}

# Call the function to symlink all .sh files
symlink_all_scripts


# Configure shell history
export HISTFILE="$XDG_STATE_HOME/bash/bash_history"
create_dir "$(dirname "$HISTFILE")"

# Configure readline inputrc
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
create_dir "$(dirname "$INPUTRC")"

# Configure GnuPG home directory
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
create_dir "$GNUPGHOME" 700

# Default applications
declare -A DEFAULT_APPS=(
    ["EDITOR"]="nvim"
    ["VISUAL"]="nvim"
    ["TERMINAL"]="wezterm"
    ["BROWSER"]="brave"
    ["IMAGE_VIEWER"]="nsxiv"
    ["DOCUMENT_VIEWER"]="zathura"
    ["VIDEO_PLAYER"]="vlc"
    ["OFFICE_SUITE"]="libreoffice"
)

# Export default applications
for app in "${!DEFAULT_APPS[@]}"; do
    export "$app"="${DEFAULT_APPS[$app]}"
    log_debug "Set $app=${DEFAULT_APPS[$app]}"
done

# Source the source-utils.sh
SOURCE_UTILS_FILE="$XDG_CONFIG_HOME/bash/functions/source-utils.sh"
if [[ -f "$SOURCE_UTILS_FILE" ]]; then
    log_debug "Sourcing source-utils from $SOURCE_UTILS_FILE"
    source "$SOURCE_UTILS_FILE"
else
    printf "Warning: source-utils.sh file not found: %s\n" "$SOURCE_UTILS_FILE"
fi

source_all_directories

export D=$(echo "$HOME/Desktop")

# Source the .bashrc file if it exists
BASHRC_FILE="$XDG_CONFIG_HOME/bash/.bashrc"
if [[ -f "$BASHRC_FILE" ]]; then
    log_debug "Sourcing .bashrc from $BASHRC_FILE"
    . "$BASHRC_FILE"
else
    printf "Warning: .bashrc file not found: %s\n" "$BASHRC_FILE"
fi
