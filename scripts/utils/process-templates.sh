#!/bin/bash

# Script to manually process chezmoi templates for testing
# This helps us test the modular system without dealing with chezmoi apply issues

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/colors.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/colors.sh"
else
    echo "Warning: colors.sh not found"
fi

print_status "INFO" "Processing chezmoi templates for testing..."

# Create output directory
OUTPUT_DIR="$HOME/.zsh-test"
mkdir -p "$OUTPUT_DIR"

# Process main zshrc
print_status "INFO" "Processing main zshrc..."
chezmoi execute-template --source . home/dot_zshrc > "$OUTPUT_DIR/zshrc"

# Process modular files
print_status "INFO" "Processing modular files..."
chezmoi execute-template --source . home/dot_zsh/paths.zsh > "$OUTPUT_DIR/paths.zsh"
chezmoi execute-template --source . home/dot_zsh/tools.zsh > "$OUTPUT_DIR/tools.zsh"
chezmoi execute-template --source . home/dot_zsh/platform.zsh > "$OUTPUT_DIR/platform.zsh"
chezmoi execute-template --source . home/dot_zsh/env.zsh > "$OUTPUT_DIR/env.zsh"
chezmoi execute-template --source . home/dot_zsh/modules.zsh > "$OUTPUT_DIR/modules.zsh"

# Copy aliases and functions (these don't have templates)
print_status "INFO" "Copying aliases and functions..."
cp -r home/dot_zsh/aliases "$OUTPUT_DIR/"
cp -r home/dot_zsh/functions "$OUTPUT_DIR/"

print_status "OK" "Templates processed successfully to $OUTPUT_DIR"
print_status "INFO" "You can test the modular system by sourcing $OUTPUT_DIR/zshrc" 