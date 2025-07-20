# shellcheck disable=all
# Linux-specific PATH and environment setup
# This file contains chezmoi template syntax which will be processed by chezmoi

# Linux paths
{{- if .nix -}}
# Nix paths are handled by Nix itself
{{- else -}}
export PATH="/usr/local/bin:$PATH"
{{- end -}}

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