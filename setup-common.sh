#!/bin/bash

# Installers shared by setup-mac.sh and setup-arch.sh: tools installed via
# their official curl scripts, identically on every platform. Sourced, not run.

# Function to put ~/.local/bin on PATH for the rest of this run.
# mise and Claude Code install there, which isn't on PATH until the next
# shell starts. Add it now so later steps (e.g. setup_mise) can find them.
ensure_local_bin_on_path() {
    case ":${PATH}:" in
        *":${HOME}/.local/bin:"*) ;;
        *) export PATH="${HOME}/.local/bin:${PATH}" ;;
    esac
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

# Function to install Claude Code if missing
install_claude_code() {
    if command -v claude >/dev/null 2>&1; then
        echo "[INFO] Claude Code already installed"
        return 0
    fi

    echo "[INFO] Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
}

# Function to install every tool above
install_common_tools() {
    ensure_local_bin_on_path
    install_starship
    install_mise
    install_claude_code
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
