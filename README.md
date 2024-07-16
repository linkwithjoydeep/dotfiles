
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

# Other dependencies


## xcode
```
xcode-select --install
```

## Install home brew
```
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Tools
```
brew install wget git fzf ripgrep starship zoxide tmux neovim lua luarocks fd
brew install --cask wezterm jumpcut
```

## install wezterm term definition
```
tempfile=$(mktemp) \
  && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
  && tic -x -o ~/.terminfo $tempfile \
  && rm $tempfile
```

## install antidote zsh package manager
```
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
```

## starship prompt
```
curl -sS https://starship.rs/install.sh | sh
```

## tmux plugin manager
```
git clone https://github.com/tmux-plugins/tpm $XDG_CONFIG_HOME/tmux/plugins/tpm
```

## Install node version manager and node
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install node
nvm alias default node
npm install --global yarn
```


