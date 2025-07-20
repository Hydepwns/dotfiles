# shellcheck disable=all
# Platform-specific aliases and settings for DROO's dotfiles

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific aliases and settings
    alias copy="pbcopy"
    alias paste="pbpaste"
    alias ls="ls -G"
    alias flushdns="sudo dscacheutil -flushcache"

    # iTerm2 integration
    if [ -e "$HOME/.iterm2_shell_integration.zsh" ]; then
        source "$HOME/.iterm2_shell_integration.zsh"
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
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
fi

# Common aliases (cross-platform)
alias ll="ls -la"
alias cm="chezmoi"

# VS Code integration
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" -- args $* ;} 