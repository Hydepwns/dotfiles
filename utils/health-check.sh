#!/usr/bin/env bash

echo "=== Dotfiles Health Check ==="

# Check chezmoi
if command -v chezmoi >/dev/null 2>&1; then
    echo "✓ chezmoi: $(chezmoi --version | head -1)"
else
    echo "✗ chezmoi: Not found"
fi

# Check git
if command -v git >/dev/null 2>&1; then
    echo "✓ git: $(git --version)"
    if git config user.name >/dev/null 2>&1; then
        echo "  - User: $(git config user.name) <$(git config user.email)>"
    else
        echo "  - No git user configured"
    fi
else
    echo "✗ git: Not found"
fi

# Check shell
echo "✓ Shell: $SHELL ($BASH_VERSION)"

# Check dotfiles status
if [[ -f ~/.zshrc ]]; then
    echo "✓ ZSH config: ~/.zshrc exists"
else
    echo "✗ ZSH config: ~/.zshrc missing"
fi

if [[ -f ~/.gitconfig ]]; then
    echo "✓ Git config: ~/.gitconfig exists"
else
    echo "✗ Git config: ~/.gitconfig missing"
fi

# Check chezmoi status
if command -v chezmoi >/dev/null 2>&1; then
    echo ""
    echo "Chezmoi status:"
    chezmoi status | head -5
    if [[ $(chezmoi status | wc -l) -gt 5 ]]; then
        echo "... ($(chezmoi status | wc -l) total files)"
    fi
fi

echo ""
echo "Health check complete!"