#!/bin/bash
# SigNoz MCP server setup

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../utils/logging.sh
source "$DOTFILES_ROOT/scripts/utils/logging.sh"

INSTALL_DIR="$HOME/.local/bin"
CLONE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/signoz-mcp-server"
BINARY_NAME="signoz-mcp-server"

install_signoz_mcp() {
    if [[ -x "$INSTALL_DIR/$BINARY_NAME" ]]; then
        info "signoz-mcp-server already installed: $INSTALL_DIR/$BINARY_NAME"
        return 0
    fi

    if ! command -v go &>/dev/null; then
        error "Go is required to build signoz-mcp-server"
        info "Install Go via: mise install go@latest"
        exit 1
    fi

    info "Cloning signoz-mcp-server..."
    if [[ -d "$CLONE_DIR" ]]; then
        git -C "$CLONE_DIR" pull --quiet
    else
        git clone --quiet https://github.com/SigNoz/signoz-mcp-server.git "$CLONE_DIR"
    fi

    info "Building signoz-mcp-server..."
    (cd "$CLONE_DIR" && go build -o "$INSTALL_DIR/$BINARY_NAME" ./cmd/server/)

    success "signoz-mcp-server installed to $INSTALL_DIR/$BINARY_NAME"
}

update_signoz_mcp() {
    if [[ ! -d "$CLONE_DIR" ]]; then
        error "signoz-mcp-server not installed yet, run install first"
        exit 1
    fi

    info "Updating signoz-mcp-server..."
    git -C "$CLONE_DIR" pull --quiet
    (cd "$CLONE_DIR" && go build -o "$INSTALL_DIR/$BINARY_NAME" ./cmd/server/)
    success "signoz-mcp-server updated"
}

show_status() {
    echo ""
    echo "SigNoz MCP Server Status:"
    echo ""

    if [[ -x "$INSTALL_DIR/$BINARY_NAME" ]]; then
        echo "  Binary: $INSTALL_DIR/$BINARY_NAME"
    else
        echo "  Binary: not installed"
    fi

    if [[ -x "$INSTALL_DIR/signoz-mcp-wrapper.sh" ]]; then
        echo "  Wrapper: $INSTALL_DIR/signoz-mcp-wrapper.sh"
    else
        echo "  Wrapper: not found (run chezmoi apply)"
    fi

    if command -v op &>/dev/null; then
        if op item get "SigNoz API Key" --vault Employee &>/dev/null 2>&1; then
            echo "  API Key: stored in 1Password"
        else
            echo "  API Key: not found in 1Password (Employee/SigNoz API Key)"
        fi
    else
        echo "  API Key: 1Password CLI not available"
    fi

    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Setup SigNoz MCP server (built from source)

Commands:
    install     Clone, build, and install (default)
    update      Pull latest and rebuild
    status      Show current status
    help        Show this help

EOF
}

main() {
    case "${1:-install}" in
        install)
            install_signoz_mcp
            show_status
            ;;
        update)
            update_signoz_mcp
            show_status
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
