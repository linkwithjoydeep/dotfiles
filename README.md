# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Notes to self for setting up a new machine.

## macOS

1. Key repeat speed:
   ```bash
   defaults write -g InitialKeyRepeat -int 10
   defaults write -g KeyRepeat -int 1
   ```
2. `./setup-mac.sh` — sets up zsh XDG dirs + `ZDOTDIR` redirect (sudo, idempotent), `brew bundle` (includes JetBrainsMono Nerd Font, the ghostty/kitty fallback font), stow, `mise install`.
3. Restart terminal (ZDOTDIR only applies to new shells).
4. Manual, can't script:
   - 1Password app > Settings > Developer > enable "Use the SSH agent", then `op signin`
   - In each repo: `git-sign-work` / `git-sign-personal` to set commit signing key
   - `tmux` then `Ctrl+b, Shift+I` to install plugins via TPM
   - If you own DankMono, patch/install its Nerd Font variant yourself (paid font, can't be scripted) — see "Layout notes" below for how it's picked up

## Linux (Fedora, Arch)

`./setup-fedora.sh` — same idea via `dnf` + `linux-package-list.txt` + `fedora-package-list.txt`, installs `starship`/`mise`/JetBrainsMono Nerd Font if missing, stow, `mise install`. Same manual steps as above.

`./setup-arch.sh` — same idea via `pacman -Syu` + `linux-package-list.txt` + `arch-package-list.txt` (lazygit and JetBrainsMono Nerd Font both ship in Arch's `extra` repo, no copr/manual install needed), installs `starship`/`mise` if missing, stow, `mise install`. Same manual steps as above.

`linux-package-list.txt` holds packages whose name is identical in both `dnf` and `pacman`. `fedora-package-list.txt` / `arch-package-list.txt` hold the exceptions: `gh` is named `github-cli` on Arch, `tectonic` isn't packaged for Fedora at all (the Fedora script prints a tip to install it manually), and JetBrainsMono Nerd Font is `ttf-jetbrains-mono-nerd` on Arch but has no Fedora package at all. `starship`/`mise`/JetBrainsMono Nerd Font (on Fedora) are intentionally in neither list — Fedora doesn't ship them in official repos, so the Fedora script installs them via `curl` instead, matching what `brew` does on macOS.

Homebrew-only casks (OrbStack, Jumpcut) have no Linux equivalent, skipped. Ghostty/Bruno/1Password aren't installed by the script — install via distro's usual channel.

Adapting for another distro: swap the package manager + list file names, check `/etc/zshenv` path (Debian/Ubuntu use `/etc/zsh/zshenv`).

## Re-apply after editing configs

```bash
brew bundle                                      # or pacman -Syu --needed $(cat linux-package-list.txt arch-package-list.txt) / dnf install -y $(cat linux-package-list.txt fedora-package-list.txt)
stow --no-folding --target="${HOME}" */          # or a single package, e.g. `zsh`
mise install
```

`stow -D <package>` to unstow.

`--no-folding` keeps directories like `~/.config/1Password` as real directories (only the files actually tracked in the repo, e.g. `ssh/agent.toml`, become symlinks), so app-managed files it writes later (1Password's sqlite/settings files) stay out of the repo instead of landing inside a stow-created directory symlink. If you set a machine up before this flag was added, one-time fix: `stow -D <package>` to remove the old folded symlink, then `stow --no-folding --target="${HOME}" <package>` to relink it per-file.

## Layout notes

- `mise/.config/mise/config.toml` — pinned tool versions, activated via `zsh/.config/zsh/devtools.zsh`.
- `1Password/.config/1Password/ssh/agent.toml` — enables SSH agent for Personal + Work vault keys.
- `zsh/.config/zsh/aliases.zsh` — `git-sign-work`/`git-sign-personal` pull signing key from 1Password.
- Each top-level folder (`zsh/`, `nvim/`, `tmux/`, ...) mirrors its target path under `$HOME`, symlinked in by stow.
- Font fallback: ghostty/kitty both default to JetBrainsMono Nerd Font, installed by the setup scripts on every machine; DankMono Nerd Font (paid, installed by hand) is preferred where present. Ghostty supports this natively via a repeated `font-family` line. kitty has no such fallback list for `font_family`, so `kitty/.config/kitty/kitty.conf` instead does `globinclude font-local.conf` — an untracked, machine-local file (not managed by stow) that you create as `~/.config/kitty/font-local.conf` with `font_family DankMono Nerd Font` on machines that have it; `globinclude` silently no-ops where that file doesn't exist.
