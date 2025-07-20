# shellcheck disable=all
# macOS-specific environment setup
# This file contains chezmoi template syntax which will be processed by chezmoi

# Homebrew configuration
eval "$({{ .brewPrefix }}/bin/brew shellenv)"

# Apple Silicon specific configurations
if [[ "$(arch)" = "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

# macOS-specific aliases
alias copy="pbcopy"
alias paste="pbpaste"
alias ls="ls -G"
alias flushdns="sudo dscacheutil -flushcache"

# iTerm2 integration
test -e "{{ .chezmoi.homeDir }}/.iterm2_shell_integration.zsh" && source "{{ .chezmoi.homeDir }}/.iterm2_shell_integration.zsh"
