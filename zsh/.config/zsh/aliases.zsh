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
alias lg="lazygit"

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
  local item="$1" email key op_ssh_sign

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not inside a git repo." >&2
    return 1
  fi

  if [[ -x "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ]]; then
    op_ssh_sign="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  elif [[ -x "/opt/1Password/op-ssh-sign" ]]; then
    op_ssh_sign="/opt/1Password/op-ssh-sign"
  elif command -v op-ssh-sign >/dev/null 2>&1; then
    op_ssh_sign="$(command -v op-ssh-sign)"
  else
    echo "Couldn't find the op-ssh-sign binary (checked macOS app bundle, /opt/1Password, and PATH)." >&2
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
  git config gpg.ssh.program "$op_ssh_sign"
  git config commit.gpgsign true
  git config tag.gpgsign true

  echo "✅ $item → $email  ($(git rev-parse --show-toplevel))"
}

git-sign-work() { _git-set-signing "work-signing" }
git-sign-personal() { _git-set-signing "personal-signing" }

# TMUX
# Basic session management
alias tm='tmux'
alias tma='tmux attach'                    # attach to last/default session
alias tmat='tmux attach -t'                # attach to named session
alias tmn='tmux new -s'                    # new named session
alias tml='tmux ls'                        # list sessions
alias tmk='tmux kill-session -t'           # kill named session
alias tmka='tmux kill-server'              # nuke everything

# Rename / detach
alias tmr='tmux rename-session'
alias tmd='tmux detach'

# Smart attach-or-create
tms() {
  tmux new-session -A -s "${1:-main}"
}
