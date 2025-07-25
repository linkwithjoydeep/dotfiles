# Only run on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    return 0
fi

# Determine Homebrew prefix based on architecture
if [[ "$(uname -m)" == "arm64" ]]; then
    # Apple Silicon
    HOMEBREW_PREFIX="/opt/homebrew"
else
    # Intel Mac
    HOMEBREW_PREFIX="/usr/local"
fi

# Check if Homebrew is installed
if [[ ! -f "$HOMEBREW_PREFIX/bin/brew" ]]; then
    echo "Warning: Homebrew not found at $HOMEBREW_PREFIX" >&2
    return 1
fi

# Initialize Homebrew environment
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# Disable auto update for every install
export HOMEBREW_NO_AUTO_UPDATE=1
