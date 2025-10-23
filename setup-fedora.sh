#!/bin/bash

sudo dnf copr enable -y dejan/lazygit
sudo dnf install -y $(cat linux-package-list.txt)
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

