# shellcheck disable=all
# Platform-specific aliases and settings for DROO's dotfiles

# Common aliases (cross-platform)
alias ll="ls -la"
alias cm="chezmoi"

# VS Code integration
code() { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" -- args $* ;}
