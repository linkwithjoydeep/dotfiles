# Better cd
alias cd='z'

# Better ls
alias ls='eza --icons=auto'

# Detailed listing
alias ll='eza -lh --icons=auto --git'

# Detailed listing including hidden files
alias la='eza -lah --icons=auto --git'

# Tree view
alias tree='eza --tree --icons=auto'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# Better cat
alias cat='bat'

# =========================================================
# Core utilities
# =========================================================

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

# =========================================================
# Editor
# =========================================================

alias vim='nvim'

# =========================================================
# Git
# =========================================================

alias glog='PAGER="less -F -X" git log'                              # -F quit if one screen, -X no clear on exit
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# =========================================================
# SSH
# =========================================================

# Ghostty sets TERM=xterm-ghostty, which most remote servers don't have a
# terminfo entry for (causes "unknown terminal type" errors on e.g. `clear`).
# Force a widely-supported TERM for remote sessions instead.
ssh() {
    TERM=xterm-256color command ssh "$@"
}


