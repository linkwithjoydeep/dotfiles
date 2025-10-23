export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}

# Set $ZDOTDIR here to be able to store your other Zsh dotfiles
# outside of $HOME.
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
