if ! command -v starship >/dev/null 2>&1; then
    echo "Warning: starship not found" >&2
    return 1
fi

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
eval "$(starship init zsh)"
