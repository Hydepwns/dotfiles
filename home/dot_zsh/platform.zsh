# shellcheck disable=all
# Platform-specific aliases and settings for DROO's dotfiles
# This file contains chezmoi template syntax which will be processed by chezmoi

# macOS-specific aliases and settings
{{- if eq .chezmoi.os "darwin" -}}
alias copy="pbcopy"
alias paste="pbpaste"
alias ls="ls -G"
alias flushdns="sudo dscacheutil -flushcache"

# iTerm2 integration
test -e "{{ .chezmoi.homeDir }}/.iterm2_shell_integration.zsh" && source "{{ .chezmoi.homeDir }}/.iterm2_shell_integration.zsh"

{{- else if eq .chezmoi.os "linux" -}}
# Linux-specific aliases and settings
alias copy="xclip -selection clipboard"
alias paste="xclip -selection clipboard -o"
alias ls="ls --color=auto"
alias open="xdg-open"

# Kitty terminal integration
if [[ "$TERM" == "xterm-kitty" ]]; then
    alias icat="kitty +kitten icat"
    alias ssh="kitty +kitten ssh"
fi
{{- end -}}

# Common aliases (cross-platform)
alias ll="ls -la"
alias cm="chezmoi"

# VS Code integration
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" -- args $* ;} 