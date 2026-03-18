#!/bin/bash
# Mise runtime version manager setup
# Handles: binary install, tool version install, status, upgrade, diagnostics

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../utils/logging.sh
source "$DOTFILES_ROOT/scripts/utils/logging.sh"

# shellcheck source=../utils/constants.sh
source "$DOTFILES_ROOT/scripts/utils/constants.sh" 2>/dev/null || true

MISE_CONFIG="$HOME/.config/mise/config.toml"

# =============================================================================
# Install
# =============================================================================

install() {
    # Install mise binary if missing
    if ! command -v mise &>/dev/null; then
        log_info "Installing mise..."
        if [[ "$PLATFORM" == "macos" ]]; then
            if command -v brew &>/dev/null; then
                brew install mise
            else
                log_error "Homebrew not found. Install brew first."
                return 1
            fi
        else
            curl https://mise.jdx.dev/install.sh | sh
        fi
        log_success "mise installed"
    else
        log_info "mise already installed: $(mise --version)"
    fi

    # Trust config files to avoid interactive prompts
    if [[ -f "$MISE_CONFIG" ]]; then
        log_info "Trusting mise config..."
        mise trust "$MISE_CONFIG" 2>/dev/null || true
    fi

    # Install tool versions
    log_info "Installing tool versions..."
    mise install --yes
    log_success "mise tool versions installed"
}

# =============================================================================
# Status
# =============================================================================

status() {
    echo "Mise Status:"
    echo ""

    if command -v mise &>/dev/null; then
        printf "  %-20s %s\n" "Version:" "$(mise --version)"
    else
        printf "  %-20s %s\n" "Version:" "not installed"
        return 0
    fi

    if [[ -f "$MISE_CONFIG" ]]; then
        printf "  %-20s %s\n" "Config:" "$MISE_CONFIG"
    else
        printf "  %-20s %s\n" "Config:" "not found"
    fi

    echo ""
    echo "  Installed tools:"
    mise ls 2>/dev/null | sed 's/^/    /' || echo "    (none)"
    echo ""
}

# =============================================================================
# Upgrade
# =============================================================================

upgrade() {
    if ! command -v mise &>/dev/null; then
        log_error "mise not installed. Run: $0 install"
        return 1
    fi

    log_info "Upgrading mise tool versions..."
    mise upgrade --yes
    log_success "mise tools upgraded"
}

# =============================================================================
# Doctor
# =============================================================================

doctor() {
    if ! command -v mise &>/dev/null; then
        log_error "mise not installed. Run: $0 install"
        return 1
    fi

    mise doctor
}

# =============================================================================
# Main
# =============================================================================

show_usage() {
    cat <<EOF
Usage: $0 [COMMAND]

Manage mise runtime versions

Commands:
    install     Install mise and all configured tool versions (default)
    status      Show mise version and installed tools
    upgrade     Upgrade mise tool versions
    doctor      Run mise diagnostics
    help        Show this help message

EOF
}

main() {
    case "${1:-install}" in
        install)
            install
            ;;
        status)
            status
            ;;
        upgrade)
            upgrade
            ;;
        doctor)
            doctor
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
