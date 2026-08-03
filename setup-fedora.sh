#!/bin/bash

set -e  # Exit on any error

# Function to set up XDG state/cache dirs zsh relies on before it ever starts
setup_zsh_dirs() {
    echo "[INFO] Creating XDG cache/state directories for zsh..."
    mkdir -p "$HOME/.cache/zsh"
    mkdir -p "$HOME/.local/state/zsh"
    mkdir -p "$HOME/.config/zsh"
}

# Function to point the system-wide zshenv at our XDG-based ZDOTDIR
# NOTE: Fedora/RHEL's zsh package uses /etc/zshenv (same as upstream zsh).
# Debian/Ubuntu's zsh package patches this to /etc/zsh/zshenv instead --
# adjust the path below if you're adapting this for a Debian-based distro.
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

# Function to install packages via dnf
install_packages() {
    if [ ! -f "linux-package-list.txt" ]; then
        echo "[ERROR] linux-package-list.txt not found in current directory"
        echo "[TIP] Run this script from the directory containing it"
        exit 1
    fi

    echo "[INFO] Enabling lazygit copr..."
    sudo dnf copr enable -y dejan/lazygit

    echo "[INFO] Installing packages from linux-package-list.txt..."
    sudo dnf install -y $(cat linux-package-list.txt)
}

# Function to install starship if missing
install_starship() {
    if command -v starship >/dev/null 2>&1; then
        echo "[INFO] starship already installed"
        return 0
    fi

    echo "[INFO] Installing starship..."
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y
}

# Function to install mise if missing
install_mise() {
    if command -v mise >/dev/null 2>&1; then
        echo "[INFO] mise already installed"
        return 0
    fi

    echo "[INFO] Installing mise..."
    curl -fsSL https://mise.run | sh
}

# Function to run stow
run_stow() {
    echo "[INFO] Setting up dotfiles with stow..."

    if ! command -v stow >/dev/null 2>&1; then
        echo "[ERROR] stow command not found. Make sure stow is installed."
        echo "[TIP] Add 'stow' to linux-package-list.txt"
        return 1
    fi

    local stow_dirs=($(find . -maxdepth 1 -type d -not -name "." -not -name ".git" | sort))

    if [ ${#stow_dirs[@]} -eq 0 ]; then
        echo "[WARNING] No directories found to stow"
        return 0
    fi

    echo "[INFO] Found directories to stow: ${stow_dirs[*]}"

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

# Function to install tool versions pinned via mise
setup_mise() {
    if ! command -v mise >/dev/null 2>&1; then
        echo "[WARNING] mise not found on PATH, skipping 'mise install'"
        return 0
    fi

    echo "[INFO] Installing tool versions with mise..."
    mise install
}

# Main execution
main() {
    echo "[INFO] Setting up zsh XDG directories..."
    setup_zsh_dirs
    setup_zdotdir

    echo "[INFO] Setting up packages..."
    install_packages
    install_starship
    install_mise

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
    echo "[TIP] Install 1Password + the 1Password CLI (https://1password.com/downloads/linux)"
    echo "      for the SSH agent and git commit signing to work."
    echo "[TIP] Inside a repo, run 'git-sign-work' or 'git-sign-personal' to configure commit signing via 1Password."
    echo "[TIP] Start tmux and press 'Ctrl+b, Shift+I' to install tmux plugins via TPM."
}

# Run main function
main "$@"
