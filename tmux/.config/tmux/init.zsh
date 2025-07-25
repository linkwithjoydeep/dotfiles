if [[ ! -f "$XDG_CONFIG_HOME/tmux/plugins/tpm/tpm" ]]; then
    echo "Installing tmux plugin manager..." >&2
    git clone https://github.com/tmux-plugins/tpm $XDG_CONFIG_HOME/tmux/plugins/tpm
fi
