#!/bin/bash

# Simple test script for dotfiles validation
echo "🧪 Testing dotfiles configuration..."

# Test 1: Check if chezmoi is installed
echo -n "Testing chezmoi installation... "
if command -v chezmoi >/dev/null 2>&1; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 2: Check if zshrc exists
echo -n "Testing zshrc existence... "
if [ -f ~/.zshrc ]; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 3: Check zshrc syntax
echo -n "Testing zshrc syntax... "
if zsh -n ~/.zshrc 2>/dev/null; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    echo "Syntax error in ~/.zshrc"
    exit 1
fi

# Test 4: Check if Oh My Zsh is installed (if enabled)
if grep -q "ohmyzsh = true" chezmoi.toml; then
    echo -n "Testing Oh My Zsh installation... "
    if [ -d ~/.oh-my-zsh ]; then
        echo "✓ PASS"
    else
        echo "✗ FAIL"
        exit 1
    fi
fi

# Test 5: Check if modular zsh directory exists
echo -n "Testing modular zsh directory... "
if [ -d ~/.zsh ]; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 6: Check if modules.zsh exists
echo -n "Testing modules.zsh existence... "
if [ -f ~/.zsh/modules.zsh ]; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

# Test 7: Check modules.zsh syntax
echo -n "Testing modules.zsh syntax... "
if zsh -n ~/.zsh/modules.zsh 2>/dev/null; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    echo "Syntax error in ~/.zsh/modules.zsh"
    exit 1
fi

# Test 8: Check if chezmoi configuration is valid
echo -n "Testing chezmoi configuration... "
if chezmoi verify >/dev/null 2>&1; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
    exit 1
fi

echo ""
echo "🎉 All tests passed! Your dotfiles are working correctly."
