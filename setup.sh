#!/bin/bash

# Enable optional debugging
DEBUG=0

log_debug() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown Time")
    [ "$DEBUG" -eq 1 ] && printf "[DEBUG] [%s] %s\n" "$timestamp" "$1"
}

# Install system dependencies
install_dependencies() {
    echo "Checking and installing dependencies..."

    # Define all required dependencies based on the provided scripts
    dependencies=(
        "git" "fzf" "tmux" "docker" "neovim" "wget" "rsync" "coreutils" "findutils" 
        "ffmpeg" "magick" "zathura" "yt-dlp" "wezterm" "xdotool" "xwininfo" "dmenu" 
        "bc" "uuidgen" "md5sum" "screenkey" "scrot" "xclip" "firefox" "vlc"
    )

    # Use appropriate package manager
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        for dep in "${dependencies[@]}"; do
            if ! command -v "$dep" >/dev/null 2>&1; then
                echo "Installing $dep..."
                sudo apt install -y "$dep"
            else
                echo "$dep is already installed."
            fi
        done
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Syu --noconfirm
        for dep in "${dependencies[@]}"; do
            if ! command -v "$dep" >/dev/null 2>&1; then
                echo "Installing $dep..."
                sudo pacman -S --noconfirm "$dep"
            else
                echo "$dep is already installed."
            fi
        done
    elif command -v brew >/dev/null 2>&1; then
        for dep in "${dependencies[@]}"; do
            if ! command -v "$dep" >/dev/null 2>&1; then
                echo "Installing $dep..."
                brew install "$dep"
            else
                echo "$dep is already installed."
            fi
        done
    else
        echo "No supported package manager found. Please install dependencies manually."
        exit 1
    fi
}

# Symlink configuration files
symlink_config_files() {
    echo "Creating symlinks for configuration files..."

    DOTFILES_REPO="$HOME/.dotfiles"
    SYMLINK_DIR="$HOME/.config"

    # Ensure .dotfiles is a bare repository
    if [ ! -d "$DOTFILES_REPO" ]; then
        echo "ERROR: $DOTFILES_REPO does not exist or is not a bare repository."
        exit 1
    fi

    # Checkout the bare repository's files into the home directory
    git --git-dir="$DOTFILES_REPO" --work-tree="$HOME" checkout -f

    # Create symlinks for config files in ~/.config
    for config in $(git --git-dir="$DOTFILES_REPO" --work-tree="$HOME" ls-tree -r --name-only HEAD | grep -E '^\.config/'); do
        SOURCE_PATH="$HOME/$config"
        TARGET_PATH="$SYMLINK_DIR/${config#.config/}"
        mkdir -p "$(dirname "$TARGET_PATH")"
        ln -sf "$SOURCE_PATH" "$TARGET_PATH"
        log_debug "Symlinked $SOURCE_PATH to $TARGET_PATH"
    done

    # Symlink bash_scripts to ~/.bash-scripts
    BASH_SCRIPTS_SOURCE="$HOME/bash_scripts"
    BASH_SCRIPTS_TARGET="$HOME/.bash-scripts"
    if [ -d "$BASH_SCRIPTS_SOURCE" ]; then
        ln -sf "$BASH_SCRIPTS_SOURCE" "$BASH_SCRIPTS_TARGET"
        log_debug "Symlinked $BASH_SCRIPTS_SOURCE to $BASH_SCRIPTS_TARGET"
    else
        echo "ERROR: $BASH_SCRIPTS_SOURCE does not exist. Skipping symlink creation."
    fi
}

# Ensure directories exist for configs and symlinks
ensure_directories() {
    echo "Ensuring necessary directories exist..."

    # Create directories as needed
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.cache"
    mkdir -p "$HOME/Desktop"
}

# Set up additional environment configuration if necessary
setup_environment() {
    echo "Setting up environment..."

    # Source .bash_profile if it isn't already sourced
    if [ -f "$HOME/.bash_profile" ]; then
        source "$HOME/.bash_profile"
        log_debug ".bash_profile sourced"
    else
        echo "Warning: .bash_profile not found!"
    fi
}

# Final setup step (can be expanded)
final_setup() {
    echo "Performing final setup steps..."

    # You can add additional tasks here, such as cleaning up, finishing touches, etc.
    # For example, configure specific services or user preferences
}

# Main function to encapsulate all setup steps
main() {
    # Run all setup steps
    install_dependencies
    symlink_config_files
    ensure_directories
    setup_environment
    final_setup

    echo "Setup complete!"
}

# Call main function to start the setup
main
