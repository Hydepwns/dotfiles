#!/bin/bash
# Tailscale setup script for DROO's dotfiles

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../utils/logging.sh
source "$DOTFILES_ROOT/scripts/utils/logging.sh"

install_tailscale() {
    local os_type
    os_type="$(uname -s)"

    case "$os_type" in
        Darwin)
            if command -v tailscale &>/dev/null; then
                log_info "Tailscale already installed: $(tailscale version | head -1)"
                return 0
            fi

            if command -v brew &>/dev/null; then
                log_info "Installing Tailscale via Homebrew..."
                brew install --cask tailscale
            else
                log_error "Homebrew not found. Install from https://tailscale.com/download/mac"
                return 1
            fi
            ;;
        Linux)
            if command -v tailscale &>/dev/null; then
                log_info "Tailscale already installed: $(tailscale version | head -1)"
                return 0
            fi

            log_info "Installing Tailscale via official script..."
            curl -fsSL https://tailscale.com/install.sh | sh
            ;;
        *)
            log_error "Unsupported OS: $os_type"
            return 1
            ;;
    esac

    log_success "Tailscale installed successfully"
}

configure_tailscale() {
    log_info "Tailscale configuration notes:"
    echo ""
    echo "  1. Start Tailscale and authenticate:"
    echo "     sudo tailscale up"
    echo ""
    echo "  2. Enable MagicDNS (recommended):"
    echo "     - Go to admin console: https://login.tailscale.com/admin/dns"
    echo "     - Enable MagicDNS"
    echo ""
    echo "  3. For SSH access to Tailscale nodes:"
    echo "     tailscale ssh user@hostname"
    echo ""
    echo "  4. To use an exit node:"
    echo "     tailscale up --exit-node=<exit-node-name>"
    echo ""
    echo "  5. Available exit nodes in your network:"
    tailscale exit-node list 2>/dev/null || echo "     (run after authentication)"
    echo ""
}

check_status() {
    if ! command -v tailscale &>/dev/null; then
        log_error "Tailscale not installed"
        return 1
    fi

    log_info "Tailscale version: $(tailscale version | head -1)"
    echo ""
    tailscale status
}

show_usage() {
    cat <<EOF
Usage: $0 [COMMAND]

Tailscale setup and management for DROO's dotfiles

Commands:
    install     Install Tailscale
    configure   Show configuration instructions
    status      Show Tailscale status
    help        Show this help message

Examples:
    $0 install
    $0 status

EOF
}

main() {
    case "${1:-install}" in
        install)
            install_tailscale
            configure_tailscale
            ;;
        configure)
            configure_tailscale
            ;;
        status)
            check_status
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
