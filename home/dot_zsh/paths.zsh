# shellcheck disable=all
# DEPRECATED: This file is deprecated in favor of the new modular structure
# Use home/dot_zsh/core/paths.zsh instead

# Load the new modular PATH management
if [ -f "$HOME/.zsh/core/paths.zsh" ]; then
    source "$HOME/.zsh/core/paths.zsh"
fi

# Additional tool configurations
# LLVM configuration
if [ -d "/opt/homebrew/opt/llvm/bin" ]; then
    export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
fi

# PostgreSQL configuration
if [ -d "/opt/homebrew/opt/postgresql@15/bin" ]; then
    export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
fi
if [ -d "/Applications/Postgres.app/Contents/Versions/15/bin" ]; then
    export PATH="/Applications/Postgres.app/Contents/Versions/15/bin:$PATH"
fi

# Foundry configuration
if [ -d "$HOME/.foundry/bin" ]; then
    export PATH="$PATH:$HOME/.foundry/bin"
fi

# Huff configuration
if [ -d "$HOME/.huff/bin" ]; then
    export PATH="$PATH:$HOME/.huff/bin"
fi

# Solana configuration
if [ -d "$HOME/.local/share/solana/install/active_release/bin" ]; then
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
fi

# Ruby/rbenv configuration
if command -v rbenv &> /dev/null; then
    export PATH="$HOME/.rbenv/shims:$PATH"
    eval "$(rbenv init -)"
fi 