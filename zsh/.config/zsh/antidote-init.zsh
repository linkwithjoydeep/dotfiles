# Check if antidote is installed, clone if missing
if [[ ! -f "$ZDOTDIR/.antidote/antidote.zsh" ]]; then
    echo "Installing antidote plugin manager..." >&2
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
fi

# Load antidote and plugins from .zsh_plugins.txt
source $ZDOTDIR/.antidote/antidote.zsh
antidote load
