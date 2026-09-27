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
# NOTE: Arch's zsh package is built with --enable-etcdir=/etc/zsh, so the
# global zshenv is /etc/zsh/zshenv (not upstream's default /etc/zshenv).
setup_zdotdir() {
    local zshenv="/etc/zsh/zshenv"
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

# Function to install packages via pacman
install_packages() {
    if [ ! -f "arch-package-list.txt" ]; then
        echo "[ERROR] arch-package-list.txt not found in current directory"
        echo "[TIP] Run this script from the directory containing it"
        exit 1
    fi

    # Full system upgrade in the same transaction as the install, per Arch's
    # partial-upgrades-are-unsupported guidance.
    echo "[INFO] Syncing repos, upgrading system, and installing packages from arch-package-list.txt..."
    sudo pacman -Syu --needed --noconfirm $(cat arch-package-list.txt)
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
    # mise.run installs to ~/.local/bin, which isn't on PATH until the next
    # shell starts. Add it now so setup_mise can find mise in this run.
    case ":${PATH}:" in
        *":${HOME}/.local/bin:"*) ;;
        *) export PATH="${HOME}/.local/bin:${PATH}" ;;
    esac

    if command -v mise >/dev/null 2>&1; then
        echo "[INFO] mise already installed"
        return 0
    fi

    echo "[INFO] Installing mise..."
    curl -fsSL https://mise.run | sh
}

# 1Password signs both the AUR package sources and the CLI binary with this key.
ONEPASSWORD_KEY_URL="https://downloads.1password.com/linux/keys/1password.asc"

# Pinned 1Password CLI version. Bump it and re-run the script to upgrade.
OP_CLI_VERSION="2.39.0"

# Function to install the 1Password desktop app from the AUR if missing.
# Not in the official repos. The clone is only needed to build the package, so
# it's done in a throwaway dir. The script skips an installed 1Password, so to
# update, repeat the clone + makepkg -si by hand (or use an AUR helper).
install_1password() {
    if pacman -Qi 1password >/dev/null 2>&1; then
        echo "[INFO] 1Password already installed"
        return 0
    fi

    echo "[INFO] Importing the 1Password signing key..."
    curl -fsSL "$ONEPASSWORD_KEY_URL" | gpg --import

    echo "[INFO] Building and installing 1Password from the AUR..."
    local build_dir
    build_dir="$(mktemp -d)"
    (
        trap 'rm -rf "$build_dir"' EXIT
        git clone --depth 1 https://aur.archlinux.org/1password.git "$build_dir/1password"
        cd "$build_dir/1password"
        makepkg -si --noconfirm
    )
}

# Function to install the 1Password CLI if missing or not at OP_CLI_VERSION.
# Not in the official repos, so fetch the release zip, verify its signature,
# and install it to /usr/local/bin. It goes in the onepassword-cli group with
# setgid so the desktop app's CLI integration (biometric unlock) accepts it.
install_1password_cli() {
    if command -v op >/dev/null 2>&1 && [ "$(op --version)" = "$OP_CLI_VERSION" ]; then
        echo "[INFO] 1Password CLI $OP_CLI_VERSION already installed"
        return 0
    fi

    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        i?86) arch="386" ;;
        armv7l|armv6l) arch="arm" ;;
        *) echo "[ERROR] Unsupported architecture for the 1Password CLI: $(uname -m)"; return 1 ;;
    esac

    echo "[INFO] Importing the 1Password signing key..."
    curl -fsSL "$ONEPASSWORD_KEY_URL" | gpg --import

    echo "[INFO] Installing 1Password CLI $OP_CLI_VERSION ($arch)..."
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    (
        trap 'rm -rf "$tmp_dir"' EXIT
        curl -fsSL -o "$tmp_dir/op.zip" \
            "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_CLI_VERSION}/op_linux_${arch}_v${OP_CLI_VERSION}.zip"
        unzip -q -d "$tmp_dir/op" "$tmp_dir/op.zip"
        gpg --verify "$tmp_dir/op/op.sig" "$tmp_dir/op/op"
        sudo install -m 0755 "$tmp_dir/op/op" /usr/local/bin/op
        sudo groupadd -f onepassword-cli
        sudo chgrp onepassword-cli /usr/local/bin/op
        sudo chmod g+s /usr/local/bin/op
    )
}

# Function to run stow
# --no-folding: keep e.g. ~/.config/1Password a real directory (only tracked
# files inside it become symlinks) instead of stow symlinking the whole
# directory. Otherwise anything the app later writes there (1Password's
# sqlite/settings files) would physically land inside this git repo.
run_stow() {
    echo "[INFO] Setting up dotfiles with stow..."

    if ! command -v stow >/dev/null 2>&1; then
        echo "[ERROR] stow command not found. Make sure stow is installed."
        echo "[TIP] Add 'stow' to arch-package-list.txt"
        return 1
    fi

    local stow_dirs=($(find . -maxdepth 1 -type d -not -name "." -not -name ".git" | sort))

    if [ ${#stow_dirs[@]} -eq 0 ]; then
        echo "[WARNING] No directories found to stow"
        return 0
    fi

    echo "[INFO] Found directories to stow: ${stow_dirs[*]}"

    echo "[INFO] Running: stow --no-folding --target=${HOME} */"
    if stow --no-folding --target="${HOME}" */; then
        echo "[SUCCESS] Dotfiles symlinked successfully!"
    else
        echo "[ERROR] Failed to stow dotfiles. Check for conflicts."
        echo "[TIP] Use 'stow --no-folding --target=${HOME} --verbose */' to see detailed output"
        echo "[TIP] Use 'stow --no-folding --target=${HOME} --adopt */' to resolve conflicts by adopting existing files"
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
    install_1password
    install_1password_cli

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
    echo "[TIP] Enable the 1Password SSH agent (1Password app > Settings > Developer > 'Use the SSH agent'),"
    echo "      then run 'op signin' to authenticate the CLI."
    echo "[TIP] Inside a repo, run 'git-sign-work' or 'git-sign-personal' to configure commit signing via 1Password."
    echo "[TIP] Start tmux and press 'Ctrl+b, Shift+I' to install tmux plugins via TPM."
    echo "[TIP] If you've bought DankMono and installed its Nerd Font patch on this machine,"
    echo "      create ~/.config/kitty/font-local.conf with 'font_family DankMono Nerd Font'"
    echo "      to prefer it over the JetBrainsMono fallback (ghostty picks it up automatically)."
}

# Run main function
main "$@"
