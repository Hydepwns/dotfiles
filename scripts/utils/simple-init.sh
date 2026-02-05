#!/usr/bin/env bash

# Simple Script Initialization - No segfaults!
# This is a simplified alternative to script-init.sh

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

# Colors (optional)
if [[ -t 1 ]]; then
    export RED='\033[0;31m'
    export GREEN='\033[0;32m'
    export YELLOW='\033[1;33m'
    export BLUE='\033[0;34m'
    export NC='\033[0m'
else
    export RED=''
    export GREEN=''
    export YELLOW=''
    export BLUE=''
    export NC=''
fi

# Simple logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Export functions
export -f log_info log_success log_error log_warning

# Success marker
export SIMPLE_INIT_LOADED=true
