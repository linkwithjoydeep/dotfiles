# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Notes to self for setting up a new machine.

## macOS

1. Install a [NerdFont](https://www.nerdfonts.com/).
2. Key repeat speed:
   ```bash
   defaults write -g InitialKeyRepeat -int 10
   defaults write -g KeyRepeat -int 1
   ```
3. `./setup-mac.sh` — sets up zsh XDG dirs + `ZDOTDIR` redirect (sudo, idempotent), `brew bundle`, stow, `mise install`.
4. Restart terminal (ZDOTDIR only applies to new shells).
5. Manual, can't script:
   - 1Password app > Settings > Developer > enable "Use the SSH agent", then `op signin`
   - In each repo: `git-sign-work` / `git-sign-personal` to set commit signing key
   - `tmux` then `Ctrl+b, Shift+I` to install plugins via TPM

## Linux (Fedora only, WIP)

`./setup-fedora.sh` — same idea via `dnf` + `linux-package-list.txt`, installs `starship`/`mise` if missing, stow, `mise install`. Same manual steps as above.

Homebrew-only casks (OrbStack, Jumpcut) have no Linux equivalent, skipped. Ghostty/Bruno/1Password aren't installed by the script — install via distro's usual channel.

Adapting for another distro: swap `dnf`/`linux-package-list.txt`, check `/etc/zshenv` path (Debian/Ubuntu use `/etc/zsh/zshenv`).

## Re-apply after editing configs

```bash
brew bundle                        # or dnf install -y $(cat linux-package-list.txt)
stow --target="${HOME}" */         # or a single package, e.g. `zsh`
mise install
```

`stow -D <package>` to unstow.

## Layout notes

- `mise/.config/mise/config.toml` — pinned tool versions, activated via `zsh/.config/zsh/devtools.zsh`.
- `1Password/.config/1Password/ssh/agent.toml` — enables SSH agent for Personal + Work vault keys.
- `zsh/.config/zsh/aliases.zsh` — `git-sign-work`/`git-sign-personal` pull signing key from 1Password.
- Each top-level folder (`zsh/`, `nvim/`, `tmux/`, ...) mirrors its target path under `$HOME`, symlinked in by stow.
