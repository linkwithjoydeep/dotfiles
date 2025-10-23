
export EDITOR=nvim VISUAL=nvim

mkdir -p "$XDG_STATE_HOME"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"

# HISTFILE is used by interactive shells only. Plus,
# non-interactive shells & external commands don't need this var.
# Hence, we put it in your .zshrc file, since that's sourced for
# each interactive shell, and don't export it.
mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE=$XDG_STATE_HOME/zsh/.history
HISTSIZE=10000
SAVEHIST=10000



# Load Core configs
source $ZDOTDIR/opts.zsh
source $ZDOTDIR/aliases.zsh

# Load shell features
source $ZDOTDIR/completion.zsh
source $ZDOTDIR/history-search.zsh

# Load system tools
[[ -f "$XDG_CONFIG_HOME/homebrew/init.zsh" ]] && source "$XDG_CONFIG_HOME/homebrew/init.zsh"

# Load plugin manager and plugins
[[ -f "$ZDOTDIR/antidote-init.zsh" ]] && source "$ZDOTDIR/antidote-init.zsh"

# Load external tools
[[ -f "$XDG_CONFIG_HOME/starship/init.zsh" ]] && source "$XDG_CONFIG_HOME/starship/init.zsh"
[[ -f "$XDG_CONFIG_HOME/zoxide/init.zsh" ]] && source "$XDG_CONFIG_HOME/zoxide/init.zsh"
[[ -f "$XDG_CONFIG_HOME/fzf/init.zsh" ]] && source "$XDG_CONFIG_HOME/fzf/init.zsh"
[[ -f "$XDG_CONFIG_HOME/tmux/init.zsh" ]] && source "$XDG_CONFIG_HOME/tmux/init.zsh"
[[ -f "$XDG_CONFIG_HOME/nvm/init.zsh" ]] && source "$XDG_CONFIG_HOME/nvm/init.zsh"
