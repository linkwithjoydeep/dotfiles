if ! command -v fzf >/dev/null 2>&1; then
    echo "Warning: fzf not found" >&2
    return 1
fi

source <(fzf --zsh)
