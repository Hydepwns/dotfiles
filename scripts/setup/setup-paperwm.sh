#!/bin/bash
# PaperWM.spoon setup for Hammerspoon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPOON_DIR="$HOME/.hammerspoon/Spoons/PaperWM.spoon"
REPO_URL="https://github.com/mogenson/PaperWM.spoon"

# Source centralized logging
# shellcheck source=../utils/logging.sh
source "$DOTFILES_ROOT/scripts/utils/logging.sh"

install_paperwm() {
    if [[ -d "$SPOON_DIR" ]]; then
        info "PaperWM.spoon already installed at $SPOON_DIR"
        update_paperwm
        return 0
    fi

    info "Installing PaperWM.spoon..."
    mkdir -p "$(dirname "$SPOON_DIR")"
    git clone "$REPO_URL" "$SPOON_DIR"
    success "PaperWM.spoon installed"

    show_mission_control_note
}

update_paperwm() {
    if [[ ! -d "$SPOON_DIR/.git" ]]; then
        error "PaperWM.spoon not installed (or not a git repo)"
        exit 1
    fi

    info "Updating PaperWM.spoon..."
    git -C "$SPOON_DIR" pull --ff-only
    success "PaperWM.spoon updated"
}

show_status() {
    echo ""
    echo "PaperWM.spoon Status:"
    echo ""

    if [[ -d "$SPOON_DIR" ]]; then
        echo "  Installed: $SPOON_DIR"
        if [[ -d "$SPOON_DIR/.git" ]]; then
            local commit
            commit="$(git -C "$SPOON_DIR" log -1 --format='%h %s' 2>/dev/null)"
            echo "  Latest commit: $commit"
        fi
    else
        echo "  Not installed"
        echo "  Run: make setup-paperwm"
    fi

    if command -v hs &>/dev/null; then
        echo "  Hammerspoon CLI: available"
    else
        echo "  Hammerspoon CLI: not found (optional)"
    fi
    echo ""
}

show_mission_control_note() {
    echo ""
    warn "Mission Control setup required for best results:"
    echo "  System Settings > Desktop & Dock > Mission Control"
    echo "  - Uncheck 'Automatically rearrange Spaces based on most recent use'"
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Setup PaperWM.spoon scrollable tiling window manager for Hammerspoon

Commands:
    install     Clone PaperWM.spoon to Hammerspoon Spoons dir (default)
    update      Pull latest changes
    status      Show current status
    help        Show this help

EOF
}

main() {
    case "${1:-install}" in
        install)
            install_paperwm
            show_status
            ;;
        update)
            update_paperwm
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
