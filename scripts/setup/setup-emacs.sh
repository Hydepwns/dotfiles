#!/bin/bash
# Emacs setup: XDG config, tree-sitter grammars, and the emacs-plus daemon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EMACS_CONFIG_DIR="$HOME/.config/emacs"
EMACS_DOTDIR="$HOME/.emacs.d"
BREW_FORMULA="emacs-plus@31"

# Source centralized logging
# shellcheck source=../utils/logging.sh
source "$DOTFILES_ROOT/scripts/utils/logging.sh"

# Emacs resolves ~/.emacs.d before ~/.config/emacs whenever the former merely
# EXISTS -- it never checks for an init.el (startup.el, startup--xdg-or-homedot).
# A stray directory there silently disables this entire config.
check_shadow() {
    [[ -d "$EMACS_DOTDIR" ]]
}

remove_shadow() {
    if ! check_shadow; then
        return 0
    fi

    warn "$EMACS_DOTDIR exists and shadows $EMACS_CONFIG_DIR"
    echo "  Emacs prefers ~/.emacs.d whenever it exists, so the XDG config is ignored."
    echo "  Contents:"
    find "$EMACS_DOTDIR" -mindepth 1 -maxdepth 2 | sed 's/^/    /' | head -20

    if command -v trash &>/dev/null; then
        info "Moving $EMACS_DOTDIR to Trash (recoverable)..."
        trash "$EMACS_DOTDIR"
    else
        error "Refusing to delete $EMACS_DOTDIR automatically."
        echo "  Install macos-trash (brew install macos-trash) or move it aside yourself:"
        echo "    mv $EMACS_DOTDIR $EMACS_DOTDIR.bak"
        exit 1
    fi

    success "Shadow directory removed"
}

install_emacs() {
    if ! command -v emacs &>/dev/null; then
        error "emacs not found. Install it first:"
        echo "    brew install d12frosted/emacs-plus/$BREW_FORMULA"
        exit 1
    fi

    remove_shadow

    if [[ ! -f "$EMACS_CONFIG_DIR/init.el" ]]; then
        info "Deploying Emacs config via chezmoi..."
        chezmoi apply "$EMACS_CONFIG_DIR"
    fi
    success "Config present: $EMACS_CONFIG_DIR"

    # First run resolves and byte-compiles every package; it is slow but silent.
    info "Installing packages (first run takes a few minutes)..."
    emacs --batch \
        -l "$EMACS_CONFIG_DIR/early-init.el" \
        -l "$EMACS_CONFIG_DIR/init.el" \
        --eval '(princ "packages ready\n")'

    install_grammars
    restart_daemon
}

install_grammars() {
    if [[ ! -f "$EMACS_CONFIG_DIR/init.el" ]]; then
        error "Config not deployed. Run: make setup-emacs"
        exit 1
    fi

    info "Compiling tree-sitter grammars (needs a C compiler and git)..."
    emacs --batch \
        -l "$EMACS_CONFIG_DIR/early-init.el" \
        -l "$EMACS_CONFIG_DIR/init.el" \
        --eval '(droo/treesit-install-grammars)'
    success "Grammar install finished"
    # droo-lang.el decides major-mode remaps at load time based on which
    # grammars exist, so a running daemon keeps the pre-install mapping.
    info "Restart Emacs to pick up newly installed grammars: make emacs-restart"
}

restart_daemon() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        info "Not macOS; skipping brew services daemon management"
        return 0
    fi

    info "Restarting the Emacs daemon..."
    brew services restart "$BREW_FORMULA"
    success "Daemon restarted (open a frame with: emacsclient -c)"
}

show_status() {
    echo ""
    echo "Emacs Status:"
    echo ""

    if command -v emacs &>/dev/null; then
        echo "  Binary:  $(command -v emacs)"
        echo "  Version: $(emacs --version | head -1)"
    else
        echo "  Not installed"
        echo "  Run: brew install d12frosted/emacs-plus/$BREW_FORMULA"
        echo ""
        return 0
    fi

    # Ask Emacs itself rather than assuming -- this is the check that catches a
    # reappeared ~/.emacs.d.
    local resolved
    resolved="$(emacs --batch --eval '(princ user-emacs-directory)' 2>/dev/null || true)"
    echo "  Config:  ${resolved:-unknown}"

    if check_shadow; then
        echo "  Shadow:  WARNING - $EMACS_DOTDIR exists and overrides the XDG config"
    else
        echo "  Shadow:  none (~/.emacs.d absent, XDG config active)"
    fi

    if [[ -f "$EMACS_CONFIG_DIR/init.el" ]]; then
        echo "  init.el: present"
    else
        echo "  init.el: MISSING (run: make setup-emacs)"
    fi

    local elpa="$HOME/.local/share/emacs/elpa"
    if [[ -d "$elpa" ]]; then
        local count
        count="$(find "$elpa" -maxdepth 1 -mindepth 1 -type d ! -name archives | wc -l | tr -d ' ')"
        echo "  Packages: $count installed ($elpa)"
    else
        echo "  Packages: none installed"
    fi

    local grammars="$HOME/.local/share/emacs/tree-sitter"
    if [[ -d "$grammars" ]]; then
        local gcount
        gcount="$(find "$grammars" -maxdepth 1 -name 'libtree-sitter-*' | wc -l | tr -d ' ')"
        echo "  Grammars: $gcount compiled"
    else
        echo "  Grammars: none (run: make emacs-grammars)"
    fi

    if emacsclient -e '(emacs-version)' &>/dev/null; then
        echo "  Daemon:  running"
    else
        echo "  Daemon:  not running (start: brew services start $BREW_FORMULA)"
    fi

    if [[ -f "$EMACS_CONFIG_DIR/themes/synthwave84-soft-theme.el" ]]; then
        echo "  Theme:   synthwave84-soft installed"
    else
        echo "  Theme:   MISSING"
    fi
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Setup Emacs with the XDG config, tree-sitter grammars, and the emacs-plus daemon

Commands:
    install     Deploy config, install packages and grammars, restart daemon (default)
    grammars    Compile missing tree-sitter grammars
    restart     Restart the Emacs daemon
    status      Show current status
    help        Show this help

EOF
}

main() {
    case "${1:-install}" in
        install)
            install_emacs
            show_status
            ;;
        grammars)
            install_grammars
            ;;
        restart)
            restart_daemon
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
