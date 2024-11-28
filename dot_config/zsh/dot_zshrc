#!/usr/bin/env zsh

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

source $ZDOTDIR/.opts
source $ZDOTDIR/.aliases
source $ZDOTDIR/.antidote/antidote.zsh

# load zsh plugins manager
antidote load

# starship prompt
eval "$(starship init zsh)"

# use z to jump directories
eval "$(zoxide init zsh)"

# fuzzy find files
source <(fzf --zsh)

# load Node version manager
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
