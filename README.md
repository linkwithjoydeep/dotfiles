
# New Machine Setup Guide

Make Sure zsh is installed. Copy the contents for `dot_zshenv` to `$HOME/.zshenv` manually.

# Install Chezmoi and the dotfiles

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply linkwithjoydeep
```

The above command also installs chezmoi under `$HOME/bin`

# Keeping dot file up to date

On any machine, you can pull and apply the latest changes from your repo with:

```
$HOME/bin/chezmoi update -v
```

