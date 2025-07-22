#!/bin/bash

# Stepwise restoration of zsh configuration
echo "🔧 Stepwise restoration of zsh configuration..."

# Function to test configuration
test_config() {
    local step="$1"
    local description="$2"

    echo -n "Testing step $step: $description... "

    if zsh -c 'source ~/.zshrc && echo "Step $step passed"' 2>/dev/null; then
        echo "✅ PASS"
        return 0
    else
        echo "❌ FAIL"
        return 1
    fi
}

# Step 1: Test current minimal config
test_config "1" "Minimal configuration" || exit 1

# Step 2: Add modular loading (without core files)
echo -e "\nStep 2: Adding modular loading..."
cat >> ~/.zshrc << 'EOF'

# Source modular configuration (stepwise)
if [[ -d ~/.zsh ]]; then
    # Only load basic modules for now
    for file in ~/.zsh/*.zsh; do
        if [[ -f "$file" ]] && [[ "$(basename "$file")" != "modules.zsh" ]]; then
            source "$file" 2>/dev/null || echo "Warning: Failed to load $(basename "$file")"
        fi
    done
fi
EOF

test_config "2" "Modular loading" || {
    echo "❌ Modular loading failed"
    exit 1
}

# Step 3: Add core directory loading
echo -e "\nStep 3: Adding core directory..."
cat >> ~/.zshrc << 'EOF'

# Load core files
if [[ -d ~/.zsh/core ]]; then
    for file in ~/.zsh/core/*.zsh; do
        if [[ -f "$file" ]]; then
            echo "Loading $(basename "$file")..."
            source "$file" 2>/dev/null || echo "Warning: Failed to load $(basename "$file")"
        fi
    done
fi
EOF

test_config "3" "Core directory loading" || {
    echo "❌ Core directory loading failed"
    exit 1
}

# Step 4: Add aliases and functions
echo -e "\nStep 4: Adding aliases and functions..."
cat >> ~/.zshrc << 'EOF'

# Load aliases and functions
if [[ -d ~/.zsh/aliases ]]; then
    for file in ~/.zsh/aliases/*.zsh; do
        if [[ -f "$file" ]]; then
            source "$file" 2>/dev/null || echo "Warning: Failed to load $(basename "$file")"
        fi
    done
fi

if [[ -d ~/.zsh/functions ]]; then
    for file in ~/.zsh/functions/*.zsh; do
        if [[ -f "$file" ]]; then
            source "$file" 2>/dev/null || echo "Warning: Failed to load $(basename "$file")"
        fi
    done
fi
EOF

test_config "4" "Aliases and functions" || {
    echo "❌ Aliases and functions failed"
    exit 1
}

echo -e "\n✅ All steps passed! Your configuration is working."
echo "You can now restore your full configuration safely."
