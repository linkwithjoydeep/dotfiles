
# OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :


# Mise: cli integration
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
