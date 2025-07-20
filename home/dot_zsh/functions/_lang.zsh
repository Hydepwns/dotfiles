# Language-specific environment setup functions

# Rust development environment
function setup_rust() {
    export RUST_BACKTRACE=1
    export CARGO_INCREMENTAL=1
    export RUST_LOG=info
    echo "Rust environment configured"
}

# Node.js development environment
function setup_node() {
    export NODE_ENV=development
    export NPM_CONFIG_LOGLEVEL=warn
    export NODE_OPTIONS="--max-old-space-size=4096"
    echo "Node.js environment configured"
}

# Python development environment
function setup_python() {
    export PYTHONPATH="${PYTHONPATH}:$(pwd)"
    export PIPENV_VENV_IN_PROJECT=1
    export PYTHONUNBUFFERED=1
    echo "Python environment configured"
}

# Go development environment
function setup_go() {
    export GOPATH="${HOME}/go"
    export PATH="${PATH}:${GOPATH}/bin"
    export GO111MODULE=on
    echo "Go environment configured"
}

# Elixir development environment
function setup_elixir() {
    export ERL_AFLAGS="-kernel shell_history enabled"
    export ECTO_EDITOR="code"
    echo "Elixir environment configured"
}

# Web3 development environment
function setup_web3() {
    export FOUNDRY_PROFILE=default
    export ANCHOR_PROVIDER_URL=http://127.0.0.1:8899
    export ANCHOR_WALLET=~/.config/solana/id.json
    echo "Web3 environment configured"
}

# Database development environment
function setup_db() {
    export DATABASE_URL="postgresql://postgres:postgres@localhost:5432/dev"
    export REDIS_URL="redis://localhost:6379"
    echo "Database environment configured"
}

# Docker development environment
function setup_docker() {
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    echo "Docker environment configured"
}

# Kubernetes development environment
function setup_k8s() {
    export KUBECONFIG="${HOME}/.kube/config"
    export KUBE_EDITOR="code"
    echo "Kubernetes environment configured"
}

# Development environment setup
function setup_dev_env() {
    local lang=$1
    
    case $lang in
        "rust"|"rs")
            setup_rust
            ;;
        "node"|"js"|"ts"|"javascript"|"typescript")
            setup_node
            ;;
        "python"|"py")
            setup_python
            ;;
        "go"|"golang")
            setup_go
            ;;
        "elixir"|"ex")
            setup_elixir
            ;;
        "web3"|"solidity"|"sol")
            setup_web3
            ;;
        "db"|"database"|"postgres"|"redis")
            setup_db
            ;;
        "docker"|"container")
            setup_docker
            ;;
        "k8s"|"kubernetes")
            setup_k8s
            ;;
        "all")
            setup_rust
            setup_node
            setup_python
            setup_go
            setup_elixir
            setup_web3
            setup_db
            setup_docker
            setup_k8s
            echo "All development environments configured"
            ;;
        *)
            echo "Available environments: rust, node, python, go, elixir, web3, db, docker, k8s, all"
            echo "Usage: setup_dev_env <environment>"
            ;;
    esac
}

# Quick environment setup for common project types
function setup_project() {
    local project_type=$1
    
    case $project_type in
        "rust")
            setup_rust
            echo "Rust project environment ready"
            ;;
        "node"|"react"|"next"|"vue")
            setup_node
            echo "Node.js project environment ready"
            ;;
        "python"|"django"|"flask")
            setup_python
            echo "Python project environment ready"
            ;;
        "web3"|"solidity")
            setup_web3
            echo "Web3 project environment ready"
            ;;
        "fullstack")
            setup_node
            setup_python
            setup_db
            echo "Full-stack project environment ready"
            ;;
        *)
            echo "Available project types: rust, node, react, next, vue, python, django, flask, web3, solidity, fullstack"
            echo "Usage: setup_project <type>"
            ;;
    esac
}

# Environment cleanup
function cleanup_env() {
    unset RUST_BACKTRACE
    unset CARGO_INCREMENTAL
    unset NODE_ENV
    unset NPM_CONFIG_LOGLEVEL
    unset PYTHONPATH
    unset PIPENV_VENV_IN_PROJECT
    unset GOPATH
    unset ERL_AFLAGS
    unset FOUNDRY_PROFILE
    unset DATABASE_URL
    unset REDIS_URL
    unset DOCKER_BUILDKIT
    echo "Environment variables cleaned up"
} 