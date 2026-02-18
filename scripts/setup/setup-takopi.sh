#!/bin/bash
# takopi (Telegram AI agent bridge) setup

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source centralized logging
# shellcheck source=../utils/logging.sh
source "$DOTFILES_ROOT/scripts/utils/logging.sh"

# shellcheck source=../utils/constants.sh
source "$DOTFILES_ROOT/scripts/utils/constants.sh"

TAKOPI_CONFIG="$HOME/.takopi/takopi.toml"
ENCRYPTED_CONFIG="$DOTFILES_ROOT/home/dot_takopi/encrypted_takopi.toml"

install_takopi() {
    if ! command -v uv &>/dev/null; then
        error "uv not found -- install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi

    info "Installing takopi via uv..."
    uv tool install -U takopi

    if command -v takopi &>/dev/null; then
        success "takopi installed: $(takopi --version 2>/dev/null || echo 'ok')"
    else
        error "takopi installation failed"
        exit 1
    fi
}

run_onboard() {
    if ! command -v takopi &>/dev/null; then
        error "takopi not installed -- run: make setup-takopi"
        exit 1
    fi

    info "Starting takopi onboarding wizard..."
    takopi --onboard
    success "Onboarding complete"

    if [[ -f "$TAKOPI_CONFIG" ]]; then
        info "Config created at $TAKOPI_CONFIG"
        info "Run 'make takopi-backup' to encrypt and store in chezmoi"
    fi
}

config_backup() {
    if [[ ! -f "$TAKOPI_CONFIG" ]]; then
        error "No config found at $TAKOPI_CONFIG"
        error "Run 'make takopi-onboard' first"
        exit 1
    fi

    if ! command -v age &>/dev/null; then
        error "age not found -- install with: brew install age"
        exit 1
    fi

    if [[ -z "$AGE_RECIPIENT" ]]; then
        error "AGE_RECIPIENT not set -- configure age_recipient in chezmoi.toml"
        exit 1
    fi

    info "Encrypting $TAKOPI_CONFIG..."
    mkdir -p "$(dirname "$ENCRYPTED_CONFIG")"
    age -r "$AGE_RECIPIENT" -o "$ENCRYPTED_CONFIG" "$TAKOPI_CONFIG"
    success "Encrypted config saved to $ENCRYPTED_CONFIG"
    info "Verify with: chezmoi diff ~/.takopi/takopi.toml"
}

show_status() {
    echo ""
    echo "takopi Status:"
    echo ""

    if command -v takopi &>/dev/null; then
        echo "  Installed: $(command -v takopi)"
        echo "  Version: $(takopi --version 2>/dev/null || echo 'unknown')"
    else
        echo "  Not installed"
        echo "  Run: make setup-takopi"
    fi

    if [[ -f "$TAKOPI_CONFIG" ]]; then
        echo "  Config: $TAKOPI_CONFIG"
    else
        echo "  Config: not found (run: make takopi-onboard)"
    fi

    if [[ -f "$ENCRYPTED_CONFIG" ]]; then
        echo "  Encrypted backup: $ENCRYPTED_CONFIG"
    else
        echo "  Encrypted backup: not found (run: make takopi-backup)"
    fi
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Setup takopi Telegram AI agent bridge

Commands:
    install         Install takopi via uv (default)
    onboard         Run interactive onboarding wizard
    config-backup   Encrypt config to chezmoi source
    status          Show current status
    help            Show this help

EOF
}

main() {
    case "${1:-install}" in
        install)
            install_takopi
            show_status
            ;;
        onboard)
            run_onboard
            ;;
        config-backup)
            config_backup
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
