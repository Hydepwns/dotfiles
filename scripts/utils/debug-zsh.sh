#!/bin/bash

# Debug script for zsh configuration issues
echo "🔍 Debugging zsh configuration..."

# Test 1: Basic zsh without any config
echo "Test 1: Basic zsh without config"
zsh -f -c "echo 'Basic zsh works'"

# Test 2: Zsh with only .zshrc
echo -e "\nTest 2: Zsh with only .zshrc"
zsh -c "source ~/.zshrc && echo 'zshrc loaded successfully'"

# Test 3: Check which file is causing issues
echo -e "\nTest 3: Testing modular files one by one"

# Test modules.zsh
echo "Testing modules.zsh..."
zsh -c "source ~/.zsh/modules.zsh && echo 'modules.zsh loaded successfully'"

# Test core files
echo "Testing core files..."
zsh -c "source ~/.zsh/core/lazy-loading.zsh && echo 'lazy-loading.zsh loaded successfully'"

# Test other core files
for file in ~/.zsh/core/*.zsh; do
    if [[ -f "$file" ]]; then
        echo "Testing $(basename "$file")..."
        zsh -c "source \"$file\" && echo '$(basename "$file") loaded successfully'"
    fi
done

echo -e "\n✅ Debug complete!"
