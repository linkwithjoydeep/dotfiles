#!/bin/bash

set -e  # Exit on any error

# Function to install Homebrew
install_homebrew() {
    echo "[INFO] Homebrew not found. Installing Homebrew..."

    # Official Homebrew installation command
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for current session
    if [[ $(uname -m) == "arm64" ]]; then
        # Apple Silicon
        echo "[INFO] Adding Homebrew to PATH (Apple Silicon)..."
        export PATH="/opt/homebrew/bin:$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Intel
        echo "[INFO] Adding Homebrew to PATH (Intel)..."
        export PATH="/usr/local/bin:$PATH"
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo "[SUCCESS] Homebrew installation completed!"
}

# Function to detect and use brew
detect_and_use_brew() {
    # Check if brew is already in PATH
    if command -v brew >/dev/null 2>&1; then
        echo "[SUCCESS] Found brew in PATH: $(which brew)" >&2
        echo "brew"
        return 0
    # Check Apple Silicon location
    elif [ -f "/opt/homebrew/bin/brew" ]; then
        echo "[SUCCESS] Found brew at: /opt/homebrew/bin/brew" >&2
        export PATH="/opt/homebrew/bin:$PATH"
        echo "/opt/homebrew/bin/brew"
        return 0
    # Check Intel location
    elif [ -f "/usr/local/bin/brew" ]; then
        echo "[SUCCESS] Found brew at: /usr/local/bin/brew" >&2
        export PATH="/usr/local/bin:$PATH"
        echo "/usr/local/bin/brew"
        return 0
    else
        echo "[ERROR] Homebrew not found in standard locations" >&2
        return 1
    fi
}

# Function to set up XDG state/cache dirs zsh relies on before it ever starts
setup_zsh_dirs() {
    echo "[INFO] Creating XDG cache/state directories for zsh..."
    mkdir -p "$HOME/.cache/zsh"
    mkdir -p "$HOME/.local/state/zsh"
    mkdir -p "$HOME/.config/zsh"
}

# Function to point the system-wide zshenv at our XDG-based ZDOTDIR
setup_zdotdir() {
    local zshenv="/etc/zshenv"
    local marker="# >>> dotfiles ZDOTDIR"
    local block="$marker
if [[ -z \"\$XDG_CONFIG_HOME\" ]]
then
    export XDG_CONFIG_HOME=\"\$HOME/.config\"
fi

if [[ -d \"\$XDG_CONFIG_HOME/zsh\" ]]
then
    export ZDOTDIR=\"\$XDG_CONFIG_HOME/zsh\"
fi
# <<< dotfiles ZDOTDIR"

    if [ -f "$zshenv" ] && grep -qF "$marker" "$zshenv"; then
        echo "[INFO] ZDOTDIR redirect already present in $zshenv"
        return 0
    fi

    echo "[INFO] Adding ZDOTDIR redirect to $zshenv (requires sudo)..."
    printf '%s\n' "$block" | sudo tee -a "$zshenv" >/dev/null
    echo "[SUCCESS] $zshenv updated. Restart your terminal for this to take effect."
}

# Function to install tool versions pinned via mise
setup_mise() {
    if ! command -v mise >/dev/null 2>&1; then
        echo "[WARNING] mise not found on PATH, skipping 'mise install'"
        return 0
    fi

    echo "[INFO] Installing tool versions with mise..."
    mise install
}

# Function to run stow
run_stow() {
    echo "[INFO] Setting up dotfiles with stow..."

    # Check if stow is available
    if ! command -v stow >/dev/null 2>&1; then
        echo "[ERROR] stow command not found. Make sure stow is installed via Homebrew."
        echo "[TIP] Add 'brew \"stow\"' to your Brewfile"
        return 1
    fi

    # Check if there are directories to stow
    local stow_dirs=($(find . -maxdepth 1 -type d -not -name "." -not -name ".git" -not -name ".DS_Store" | sort))

    if [ ${#stow_dirs[@]} -eq 0 ]; then
        echo "[WARNING] No directories found to stow"
        return 0
    fi

    echo "[INFO] Found directories to stow: ${stow_dirs[*]}"

    # Run stow for each directory
    echo "[INFO] Running: stow --target=${HOME} */"
    if stow --target="${HOME}" */; then
        echo "[SUCCESS] Dotfiles symlinked successfully!"
    else
        echo "[ERROR] Failed to stow dotfiles. Check for conflicts."
        echo "[TIP] Use 'stow --target=${HOME} --verbose */' to see detailed output"
        echo "[TIP] Use 'stow --target=${HOME} --adopt */' to resolve conflicts by adopting existing files"
        return 1
    fi
}

# Main execution
main() {
    echo "[INFO] Setting up zsh XDG directories..."
    setup_zsh_dirs
    setup_zdotdir

    echo "[INFO] Setting up Homebrew and installing packages..."

    # Try to detect existing brew installation
    if brew_cmd=$(detect_and_use_brew); then
        echo "[INFO] Using existing Homebrew installation"
    else
        # Install if not found
        install_homebrew

        # Try detection again after installation
        if brew_cmd=$(detect_and_use_brew); then
            echo "[INFO] Using newly installed Homebrew"
        else
            echo "[ERROR] Failed to install or detect Homebrew"
            exit 1
        fi
    fi

    # Check if Brewfile exists
    if [ ! -f "Brewfile" ]; then
        echo "[ERROR] Brewfile not found in current directory"
        echo "[TIP] Create a Brewfile or run this script from the directory containing it"
        exit 1
    fi

    # Install packages from Brewfile
    echo "[INFO] Installing packages from Brewfile..."
    $brew_cmd bundle --verbose

    # Run stow after successful package installation
    if run_stow; then
        echo "[SUCCESS] Setup completed successfully!"
    else
        echo "[WARNING] Setup completed but stow failed"
        exit 1
    fi

    # Install pinned language/tool versions now that mise's config is stowed
    setup_mise

    echo "[TIP] Restart your terminal (required for the ZDOTDIR change to take effect)."
    echo "[TIP] You may also need to run:"
    if [[ $(uname -m) == "arm64" ]]; then
        echo "    eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    else
        echo "    eval \"\$(/usr/local/bin/brew shellenv)\""
    fi
    echo "[TIP] Enable the 1Password SSH agent (1Password app > Settings > Developer > 'Use the SSH agent'),"
    echo "      then run 'op signin' to authenticate the CLI."
    echo "[TIP] Inside a repo, run 'git-sign-work' or 'git-sign-personal' to configure commit signing via 1Password."
    echo "[TIP] Start tmux and press 'Ctrl+b, Shift+I' to install tmux plugins via TPM."
}

# Run main function
main "$@"
