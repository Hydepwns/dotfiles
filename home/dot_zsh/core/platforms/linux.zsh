# shellcheck disable=all
# Linux-specific environment setup
# This file contains chezmoi template syntax which will be processed by chezmoi

# Linux-specific aliases
alias copy="xclip -selection clipboard"
alias paste="xclip -selection clipboard -o"
alias ls="ls --color=auto"
alias open="xdg-open"

# Kitty terminal integration
if [[ "$TERM" == "xterm-kitty" ]]; then
    alias icat="kitty +kitten icat"
    alias ssh="kitty +kitten ssh"
fi
