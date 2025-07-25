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

* Installs all dependencies using `brew bundle` from the `Brewfile`
* Uses GNU Stow to link all configs into `~/.config`

> ✅ Recommended for first-time setup on macOS.

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
  stow --target="${HOME}/.config" */
  ```

* **Single config (e.g., zsh):**

  ```bash
  stow --target="${HOME}/.config" zsh
  ```

---

## 🍺 Brewfile

All Homebrew packages, apps, and fonts are declared in the `Brewfile`.
Update it as needed and run `brew bundle` to apply changes.

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
* After updates, use `stow` or `brew bundle` manually to apply changes.
* Use `stow -D <package>` to unstow a config cleanly.
