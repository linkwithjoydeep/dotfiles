if ! command -v zoxide >/dev/null 2>&1; then
    echo "Warning: zoxide not found" >&2
    return 1
fi

eval "$(zoxide init zsh)"
alias cd='z'
