#!/bin/bash
# Brewfile management for DROO's dotfiles

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BREWFILE="$DOTFILES_ROOT/Brewfile"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${CYAN}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1" >&2; }

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &>/dev/null; then
        error "Homebrew not installed"
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add to PATH for current session
        if [[ "$(uname -m)" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    success "Homebrew available: $(brew --version | head -1)"
}

# Install packages from Brewfile
install_packages() {
    info "Installing packages from Brewfile..."

    if [[ ! -f "$BREWFILE" ]]; then
        error "Brewfile not found: $BREWFILE"
        exit 1
    fi

    # Install packages
    brew bundle install --file="$BREWFILE" --no-lock

    success "Packages installed"
}

# Update Brewfile from current system
dump_packages() {
    info "Dumping current packages to Brewfile..."

    # Backup existing
    if [[ -f "$BREWFILE" ]]; then
        cp "$BREWFILE" "$BREWFILE.backup"
        warn "Backed up existing Brewfile"
    fi

    brew bundle dump --file="$BREWFILE" --force --describe

    success "Brewfile updated"
    info "Review changes: diff $BREWFILE.backup $BREWFILE"
}

# Check for packages not in Brewfile
check_packages() {
    info "Checking for packages not in Brewfile..."

    brew bundle check --file="$BREWFILE" 2>&1 || true

    echo ""
    info "Packages that would be removed by cleanup:"
    brew bundle cleanup --file="$BREWFILE" 2>&1 || echo "  (none)"
}

# Remove packages not in Brewfile
cleanup_packages() {
    local force="${1:-}"
    info "Removing packages not in Brewfile..."

    if [[ "$force" != "--force" ]]; then
        warn "This will uninstall packages not listed in Brewfile"
        if [[ -t 0 ]]; then
            read -rp "Continue? [y/N] " confirm
            [[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0
        else
            error "No TTY available. Use 'cleanup --force' to skip confirmation."
            exit 1
        fi
    fi

    brew bundle cleanup --file="$BREWFILE" --force

    success "Cleanup complete"
}

# Update all packages
update_packages() {
    info "Updating Homebrew and packages..."

    brew update
    brew upgrade
    brew upgrade --cask --greedy

    success "Packages updated"
}

# List packages by category
list_packages() {
    echo ""
    echo -e "${CYAN}=== Installed Packages ===${NC}"
    echo ""

    echo -e "${GREEN}Taps:${NC}"
    brew tap | sed 's/^/  /'
    echo ""

    echo -e "${GREEN}Formulae:${NC}"
    brew list --formula | wc -l | xargs echo "  Count:"
    echo ""

    echo -e "${GREEN}Casks:${NC}"
    brew list --cask | wc -l | xargs echo "  Count:"
    echo ""

    echo -e "${GREEN}Services:${NC}"
    brew services list 2>/dev/null | sed 's/^/  /' || echo "  (none)"
}

# Show package info
info_package() {
    local pkg="${1:?Package name required}"

    if brew info "$pkg" &>/dev/null; then
        brew info "$pkg"
    elif brew info --cask "$pkg" &>/dev/null; then
        brew info --cask "$pkg"
    else
        error "Package not found: $pkg"
        exit 1
    fi
}

# Search for packages
search_packages() {
    local query="${1:?Search query required}"

    echo -e "${CYAN}=== Search Results ===${NC}"
    echo ""

    echo -e "${GREEN}Formulae:${NC}"
    brew search --formula "$query" 2>/dev/null | head -20 | sed 's/^/  /'
    echo ""

    echo -e "${GREEN}Casks:${NC}"
    brew search --cask "$query" 2>/dev/null | head -20 | sed 's/^/  /'
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Brewfile management for DROO's dotfiles

Commands:
    install     Install packages from Brewfile (default)
    dump        Update Brewfile from current system
    check       Check for packages not in Brewfile
    cleanup     Remove packages not in Brewfile (--force to skip prompt)
    update      Update Homebrew and all packages
    list        List installed packages
    info <pkg>  Show info for a package
    search <q>  Search for packages
    help        Show this help

Examples:
    $0 install          # Install all packages
    $0 dump             # Save current packages to Brewfile
    $0 check            # See what would be removed
    $0 info starship    # Show info for starship

EOF
}

# Main
main() {
    # Ensure macOS
    if [[ "$(uname -s)" != "Darwin" ]]; then
        error "Brewfile management is only supported on macOS"
        exit 1
    fi

    check_homebrew

    case "${1:-install}" in
        install)
            install_packages
            ;;
        dump)
            dump_packages
            ;;
        check)
            check_packages
            ;;
        cleanup)
            cleanup_packages "$2"
            ;;
        update)
            update_packages
            ;;
        list)
            list_packages
            ;;
        info)
            info_package "$2"
            ;;
        search)
            search_packages "$2"
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
