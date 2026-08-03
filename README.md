# 🛠️ Dotfiles

Personal dotfiles for macOS and Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/).

---

## 📦 Prerequisites

### 1. Install a NerdFont

> Some terminal UIs and prompts require patched fonts. Install from:  
> 👉 [NerdFonts](https://www.nerdfonts.com/)

---

### 2. (macOS) Increase Key Repeat Speed

For faster key responsiveness on macOS:

```bash
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
````

---

## 🚀 Setup

### One-time Setup (macOS)

```bash
./setup-mac.sh
```

This script:

* Creates the XDG cache/state directories zsh needs (`~/.cache/zsh`, `~/.local/state/zsh`) and `~/.config/zsh`
* Redirects `/etc/zshenv` so zsh looks for its config under `$XDG_CONFIG_HOME/zsh` (`ZDOTDIR`) instead of `$HOME` — requires `sudo`, done once, safe to re-run
* Installs all dependencies using `brew bundle` from the `Brewfile`
* Uses GNU Stow to link all configs into `~/.config`
* Installs pinned language/tool versions with `mise install` (see [mise](#-mise) below)

> ✅ Recommended for first-time setup on macOS.
> After it finishes, **restart your terminal** — the `ZDOTDIR` redirect only takes effect in new shells.

### After First Setup

A few things aren't (and can't be) automated by the script:

* **1Password SSH agent** — in the 1Password app, go to *Settings > Developer* and enable "Use the SSH agent," then run `op signin` to authenticate the CLI. This powers both SSH auth and git commit signing (see `1Password/.config/1Password/ssh/agent.toml`).
* **Git commit signing** — inside any repo, run `git-sign-work` or `git-sign-personal` to configure that repo's commit/tag signing key via 1Password (defined in `zsh/.config/zsh/aliases.zsh`).
* **tmux plugins** — start `tmux`, then press `Ctrl+b, Shift+I` to install plugins via TPM (see [TMUX Setup](#️-tmux-setup) below).

---

### Linux Setup (WIP)

```bash
./setup-linux.sh
```

---

## 🧰 Manual Configuration (Advanced or After Edits)

If you've updated the `Brewfile` or added/modified dotfiles:

### Rerun Brew dependencies

```bash
brew bundle
```

### Rerun Stow

* **All configs:**

  ```bash
  stow --target="${HOME}" */
  ```

* **Single config (e.g., zsh):**

  ```bash
  stow --target="${HOME}" zsh
  ```

### Rerun mise

```bash
mise install
```

---

## 🍺 Brewfile

All Homebrew packages, apps, and fonts are declared in the `Brewfile`.
Update it as needed and run `brew bundle` to apply changes.

---

## 🧬 mise

Language/tool versions (Go, Node, Rust, Java, Gradle, Lua, and a couple of npm-backed
CLIs) are pinned in `mise/.config/mise/config.toml`. `mise activate` is wired into
`zsh/.config/zsh/devtools.zsh`, so once stowed, any new shell picks up the pinned
versions automatically. Run `mise install` after editing the config to fetch new pins.

---

## 🔐 1Password

`1Password/.config/1Password/ssh/agent.toml` enables the 1Password SSH agent for
both `Personal` and `Work` vault keys (auth + commit signing). After stowing:

1. In the 1Password app: *Settings > Developer* → enable "Use the SSH agent"
2. Run `op signin` to authenticate the CLI
3. In any repo, run `git-sign-work` or `git-sign-personal` (aliases in
   `zsh/.config/zsh/aliases.zsh`) to configure that repo's commit/tag signing key

---

## 🖥️ TMUX Setup

Start `tmux`:

```bash
tmux
```

Install plugins:

```text
Ctrl + b, then Shift + I
```

(This triggers plugin sync via [TPM](https://github.com/tmux-plugins/tpm))

---

## 📁 Directory Structure

Each folder (e.g., `zsh/`, `nvim/`, `tmux/`) contains config files.
These are symlinked into `~/.config/` using [GNU Stow](https://www.gnu.org/software/stow/).

---

## 💡 Tips

* `setup-mac.sh` is your go-to for initial setup.
* After updates, use `stow`, `brew bundle`, or `mise install` manually to apply changes.
* Use `stow -D <package>` to unstow a config cleanly.
* Changed `/etc/zshenv`, `Brewfile`, or `mise/.config/mise/config.toml`? Just re-run `./setup-mac.sh` — every step is idempotent.
