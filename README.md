
# Install a NerdFont
[NerdFonts](https://www.nerdfonts.com/)

# Increase MacOS key repeat speed
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# Run the setup scripts
./setup-mac.sh or setup-linux.sh

# Manually Run Stow
All configs: stow --target=${HOME} */
Specific config: stow --target=${HOME} zsh

# Additional Brew Dependencies
Update `Brewfile` and run `brew bundle`

# TMUX setup
```
tmux
```
Press ctrl + b + I (notice: shift + i)
