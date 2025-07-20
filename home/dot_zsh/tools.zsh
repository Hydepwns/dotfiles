# shellcheck disable=all
# DEPRECATED: This file is deprecated in favor of the new modular structure
# Use home/dot_zsh/core/tools.zsh instead

# Load the new modular tools configuration
if [ -f "$HOME/.zsh/core/tools.zsh" ]; then
    source "$HOME/.zsh/core/tools.zsh"
fi 