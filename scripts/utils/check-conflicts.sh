#!/bin/bash

# Script to detect function and alias conflicts in the modular system

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/colors.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/colors.sh"
else
    echo "Warning: colors.sh not found"
fi

print_status "INFO" "Checking for function and alias conflicts..."

# Get all function names from the function files
FUNCTION_FILES=(
    "home/dot_zsh/functions/_dev.zsh"
    "home/dot_zsh/functions/_docker.zsh"
    "home/dot_zsh/functions/_git.zsh"
    "home/dot_zsh/functions/_lang.zsh"
)

# Extract function names
FUNCTION_NAMES=()
for file in "${FUNCTION_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        while IFS= read -r line; do
            if [[ $line =~ ^[a-zA-Z_][a-zA-Z0-9_]*\(\) ]]; then
                func_name="${line%()}"
                FUNCTION_NAMES+=("$func_name")
            fi
        done < "$file"
    fi
done

print_status "INFO" "Found ${#FUNCTION_NAMES[@]} functions"

# Check for conflicts with existing aliases
CONFLICTS=()
for func_name in "${FUNCTION_NAMES[@]}"; do
    if alias "$func_name" &>/dev/null; then
        CONFLICTS+=("$func_name")
    fi
done

if [[ ${#CONFLICTS[@]} -eq 0 ]]; then
    print_status "OK" "No function conflicts detected!"
else
    print_status "WARN" "Found ${#CONFLICTS[@]} function conflicts:"
    for conflict in "${CONFLICTS[@]}"; do
        echo "  - $conflict"
    done
fi

# Check for conflicts with built-in commands
BUILTIN_CONFLICTS=()
for func_name in "${FUNCTION_NAMES[@]}"; do
    if command -v "$func_name" &>/dev/null; then
        BUILTIN_CONFLICTS+=("$func_name")
    fi
done

if [[ ${#BUILTIN_CONFLICTS[@]} -eq 0 ]]; then
    print_status "OK" "No conflicts with built-in commands!"
else
    print_status "WARN" "Found ${#BUILTIN_CONFLICTS[@]} conflicts with built-in commands:"
    for conflict in "${BUILTIN_CONFLICTS[@]}"; do
        echo "  - $conflict"
    done
fi

print_status "INFO" "Conflict check complete!" 