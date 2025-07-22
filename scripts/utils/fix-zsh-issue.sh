#!/bin/bash

# Temporary fix for zsh issues
echo "🔧 Temporarily fixing zsh configuration..."

# Backup current zshrc
cp ~/.zshrc ~/.zshrc.backup

# Create a minimal working zshrc
cat > ~/.zshrc << 'EOF'
# Minimal zsh configuration for debugging

# Basic PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Homebrew paths
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Basic settings
export EDITOR="vim"
export LANG="en_US.UTF-8"

# Disable mail notifications
unset MAILCHECK
unset MAIL
unset MAILPATH

# Basic aliases
alias ll="ls -la"
alias g="git"

# Oh My Zsh (if installed)
if [ -d ~/.oh-my-zsh ]; then
    export ZSH=~/.oh-my-zsh
    ZSH_THEME="robbyrussell"
    plugins=(git)
    source $ZSH/oh-my-zsh.sh
fi

echo "✅ Minimal zsh configuration loaded"
EOF

echo "✅ Created minimal zsh configuration"
echo "Try starting a new zsh session now"
