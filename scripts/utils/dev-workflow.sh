#!/bin/bash
# Development workflow helpers

# Start a development session
dev_session() {
    local project="$1"
    cd "$project" || exit 1
    
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
