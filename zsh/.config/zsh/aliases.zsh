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

# Configure git commit/tag signing for the *current* repo using a 1Password item
_git-set-signing() {
  local item="$1" email key

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not inside a git repo." >&2
    return 1
  fi

  email=$(op item get "$item" --field "email" --reveal 2>/dev/null)
  key=$(op item get "$item" --field "public key" --reveal 2>/dev/null)

  if [[ -z "$email" || -z "$key" ]]; then
    echo "Couldn't read email/public key from 1Password item '$item'." >&2
    return 1
  fi

  git config user.email "$email"
  git config user.signingkey "$key"
  git config gpg.format ssh
  git config gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  git config commit.gpgsign true
  git config tag.gpgsign true

  echo "✅ $item → $email  ($(git rev-parse --show-toplevel))"
}

git-sign-work() { _git-set-signing "work-signing" }
git-sign-personal() { _git-set-signing "personal-signing" }
