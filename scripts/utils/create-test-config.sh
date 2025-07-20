#!/bin/bash

# Script to create a test configuration without templates
# This validates the modular system structure

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/colors.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/colors.sh"
else
    echo "Warning: colors.sh not found"
fi

print_status "INFO" "Creating test configuration without templates..."

# Create output directory
OUTPUT_DIR="$HOME/.zsh-test"
mkdir -p "$OUTPUT_DIR"

# Create main zshrc
cat > "$OUTPUT_DIR/zshrc" << EOF
# shellcheck disable=all
# Main zsh configuration for DROO's dotfiles (Test Version)

# Autoload completions
autoload -U compinit
compinit -i

# Universal settings
export EDITOR="nvim"
export LANG="en_US.UTF-8"

# Source modular configuration
if [[ -f "$OUTPUT_DIR/modules.zsh" ]]; then
    # shellcheck source=/dev/null
    source "$OUTPUT_DIR/modules.zsh"
fi
EOF

# Create paths.zsh
cat > "$OUTPUT_DIR/paths.zsh" << EOF
# Centralized PATH management for DROO's dotfiles (Test Version)

# Base PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# macOS paths
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Rust configuration
export PATH="$HOME/.cargo/bin:$PATH"

# pnpm configuration
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pipx configuration
export PATH="$PATH:$HOME/.local/bin"
EOF

# Create tools.zsh
cat > "$OUTPUT_DIR/tools.zsh" << EOF
# Tool-specific configurations for DROO's dotfiles (Test Version)

# asdf configuration
if command -v asdf &> /dev/null; then
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

# direnv configuration
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi
EOF

# Create platform.zsh
cat > "$OUTPUT_DIR/platform.zsh" << EOF
# Platform-specific aliases and settings for DROO's dotfiles (Test Version)

# macOS-specific aliases and settings
alias copy="pbcopy"
alias paste="pbpaste"
alias ls="ls -G"
alias flushdns="sudo dscacheutil -flushcache"

# Common aliases (cross-platform)
alias ll="ls -la"
alias cm="chezmoi"

# VS Code integration
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" -- args "$@" ;}
EOF

# Create env.zsh
cat > "$OUTPUT_DIR/env.zsh" << EOF
# Environment settings for DROO's dotfiles (Test Version)

# DappSnap - Automatically use the correct Node.js version
if command -v nvm &> /dev/null; then
    cd() { builtin cd "$@" && if [ -f ".nvmrc" ]; then nvm use; elif [ -d "node_modules" ]; then nvm use 23.4.0; fi }
fi
EOF

# Create modules.zsh
cat > "$OUTPUT_DIR/modules.zsh" << 'EOF'
# Module loader for DROO's dotfiles (Test Version)

# Get the directory where this script is located
ZSH_MODULES_DIR="$OUTPUT_DIR"

# shellcheck disable=SC1090
if [[ -d "$ZSH_MODULES_DIR" ]]; then
    if [[ -d "$ZSH_MODULES_DIR/aliases" ]]; then
        for alias_file in "$ZSH_MODULES_DIR"/aliases/*.zsh; do
            # shellcheck disable=SC2154
            if [[ -f "$alias_file" ]]; then
                # shellcheck source=/dev/null
                source "$alias_file"
            fi
        done
    fi

    # shellcheck disable=SC1090
    if [[ -d "$ZSH_MODULES_DIR/functions" ]]; then
        for func_file in "$ZSH_MODULES_DIR"/functions/*.zsh; do
            if [[ -f "$func_file" ]]; then
                # shellcheck source=/dev/null
                source "$func_file"
            fi
        done
    fi

    # shellcheck disable=SC1090
    for module_file in "$ZSH_MODULES_DIR"/*.zsh; do
        if [[ -f "$module_file" ]] && [[ "$(basename "$module_file")" != "modules.zsh" ]]; then
            source "$module_file"
        fi
    done
fi
EOF

# Replace the placeholder with the actual path
sed -i '' "s|\$OUTPUT_DIR|$OUTPUT_DIR|g" "$OUTPUT_DIR/modules.zsh"

# Copy aliases and functions
print_status "INFO" "Copying aliases and functions..."
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cp -r "$DOTFILES_ROOT/home/dot_zsh/aliases" "$OUTPUT_DIR/aliases"
cp -r "$DOTFILES_ROOT/home/dot_zsh/functions" "$OUTPUT_DIR/functions"
cp -r "$DOTFILES_ROOT/home/dot_zsh/core" "$OUTPUT_DIR/core"

print_status "OK" "Test configuration created successfully in $OUTPUT_DIR"
print_status "INFO" "You can test the modular system by sourcing $OUTPUT_DIR/zshrc"
