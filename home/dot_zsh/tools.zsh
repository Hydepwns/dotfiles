# shellcheck disable=all
# DEPRECATED: This file is deprecated in favor of the new modular structure
# Use home/dot_zsh/core/tools.zsh instead
# This file contains chezmoi template syntax which will be processed by chezmoi

# Load the new modular tools configuration
source "{{ .chezmoi.homeDir }}/.zsh/core/tools.zsh" 