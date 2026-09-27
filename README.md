# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Notes to self for setting up a new machine.

## macOS

1. Key repeat speed:
   ```bash
   defaults write -g InitialKeyRepeat -int 10
   defaults write -g KeyRepeat -int 1
   ```
2. `./setup-mac.sh` — sets up zsh XDG dirs + `ZDOTDIR` redirect (sudo, idempotent), `brew bundle` (includes JetBrainsMono Nerd Font, the ghostty/kitty fallback font), installs the shared tools from `setup-common.sh` if missing, stow, `mise install`.
3. Restart terminal (ZDOTDIR only applies to new shells).
4. Manual, can't script:
   - 1Password app > Settings > Developer > enable "Use the SSH agent", then `op signin`
   - In each repo: `git-sign-work` / `git-sign-personal` to set commit signing key
   - `tmux` then `Ctrl+b, Shift+I` to install plugins via TPM
   - If you own DankMono, patch/install its Nerd Font variant yourself (paid font, can't be scripted) — see "Layout notes" below for how it's picked up

## Arch Linux

`./setup-arch.sh` — same idea via `pacman -Syu` + `arch-package-list.txt`, installs the shared tools from `setup-common.sh` if missing, installs 1Password + the 1Password CLI if missing, stow, `mise install`. Same manual steps as above.

1Password isn't in Arch's official repos, so the script handles both parts itself:
- **Desktop app**: built from the AUR (`1password`) with `makepkg -si` after importing 1Password's signing key. The clone lives in a temp dir that's deleted afterwards, since it's only needed to build. The script skips an installed 1Password, so to update, repeat the clone + `makepkg -si` by hand (or use an AUR helper).
- **CLI**: the official release zip for the pinned `OP_CLI_VERSION` in `setup-arch.sh`, signature-checked with `gpg --verify`, installed to `/usr/local/bin/op` in the `onepassword-cli` group with setgid (required for the desktop app integration). To upgrade, bump `OP_CLI_VERSION` and re-run.

Homebrew-only casks (OrbStack, Jumpcut) have no Linux equivalent, skipped. Ghostty/Bruno aren't installed by the script — install them via pacman/AUR.

## Shared tools

`setup-common.sh` is sourced by both setup scripts (not run directly). It holds tools installed the same way on every platform, via their official `curl` scripts: `starship`, `mise`, Claude Code. They're kept out of the Brewfile and pacman list on purpose. To add another such tool, add an `install_<tool>` function there and call it from `install_common_tools`.

## Re-apply after editing configs

```bash
brew bundle                                      # or pacman -Syu --needed $(cat arch-package-list.txt)
stow --no-folding --target="${HOME}" */          # or a single package, e.g. `zsh`
mise install
```

`docs/` holds documentation, e.g. a manual Arch Linux install guide (start at [`docs/arch-install/README.md`](docs/arch-install/README.md)). It is not a stow package: `docs/.stow-local-ignore` ignores everything in it, so `stow … */` links nothing from there.

`stow -D <package>` to unstow.

`--no-folding` keeps directories like `~/.config/1Password` as real directories (only the files actually tracked in the repo, e.g. `ssh/agent.toml`, become symlinks), so app-managed files it writes later (1Password's sqlite/settings files) stay out of the repo instead of landing inside a stow-created directory symlink. If you set a machine up before this flag was added, one-time fix: `stow -D <package>` to remove the old folded symlink, then `stow --no-folding --target="${HOME}" <package>` to relink it per-file.

## Layout notes

- `mise/.config/mise/config.toml` — pinned tool versions, activated via `zsh/.config/zsh/devtools.zsh`.
- `1Password/.config/1Password/ssh/agent.toml` — enables SSH agent for Personal + Work vault keys.
- `zsh/.config/zsh/aliases.zsh` — `git-sign-work`/`git-sign-personal` pull signing key from 1Password.
- Each top-level folder (`zsh/`, `nvim/`, `tmux/`, ...) mirrors its target path under `$HOME`, symlinked in by stow.
- Font fallback: ghostty/kitty both default to JetBrainsMono Nerd Font, installed by the setup scripts on every machine; DankMono Nerd Font (paid, installed by hand) is preferred where present. Ghostty supports this natively via a repeated `font-family` line. kitty has no such fallback list for `font_family`, so `kitty/.config/kitty/kitty.conf` instead does `globinclude font-local.conf` — an untracked, machine-local file (not managed by stow) that you create as `~/.config/kitty/font-local.conf` with `font_family DankMono Nerd Font` on machines that have it; `globinclude` silently no-ops where that file doesn't exist.
