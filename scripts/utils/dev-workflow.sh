#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1 | xargs dirname)"
source "$UTILS_DIR/script-init.sh"

# Source constants

# Development workflow helpers

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
