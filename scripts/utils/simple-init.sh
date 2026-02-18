#!/usr/bin/env bash

# Simple Script Initialization
# Source this at the top of scripts for standard utilities

# Set script directory
if [[ -z "$SCRIPT_DIR" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Find dotfiles root
find_dotfiles_root() {
    local dir="$SCRIPT_DIR"

    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/chezmoi.toml" ]] || [[ -f "$dir/Makefile" ]] || [[ -d "$dir/scripts" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    # Fallback
    echo "${HOME}/dotfiles"
}

# Set paths
export DOTFILES_ROOT="${DOTFILES_ROOT:-$(find_dotfiles_root)}"
export UTILS_DIR="${UTILS_DIR:-$DOTFILES_ROOT/scripts/utils}"

# Basic error handling
set -euo pipefail

# Source centralized logging (includes colors and all log functions)
# shellcheck source=logging.sh
source "$UTILS_DIR/logging.sh"

# Success marker
export SIMPLE_INIT_LOADED=true
