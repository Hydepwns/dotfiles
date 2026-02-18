#!/usr/bin/env bash
# Development workflow helpers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=simple-init.sh
source "$SCRIPT_DIR/simple-init.sh"

# Simple utility functions
file_exists() { test -f "$1"; }
dir_exists() { test -d "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Start a development session
dev_session() {
    local project="$1"
    cd "$project" || exit $EXIT_FAILURE

    # Auto-load environment
    if [[ -f .envrc ]]; then
        direnv allow
    fi

    # Start development server based on project type
    if [[ -f package.json ]]; then
        npm run dev
    elif [[ -f Cargo.toml ]]; then
        cargo run
    elif [[ -f mix.exs ]]; then
        mix phx.server
    fi
}
