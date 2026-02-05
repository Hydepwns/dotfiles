#!/bin/bash
# Starship prompt setup

set -e

info() { echo "[*] $1"; }
success() { echo "[+] $1"; }
warn() { echo "[!] $1"; }
error() { echo "[-] $1" >&2; }

install_starship() {
    if command -v starship &>/dev/null; then
        info "Starship already installed: $(starship --version | head -1)"
        return 0
    fi

    info "Installing Starship..."

    case "$(uname -s)" in
        Darwin)
            if command -v brew &>/dev/null; then
                brew install starship
            else
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
        Linux)
            curl -sS https://starship.rs/install.sh | sh -s -- -y
            ;;
        *)
            error "Unsupported OS"
            exit 1
            ;;
    esac

    success "Starship installed"
}

setup_config() {
    local config_file="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"

    info "Setting up Starship config..."

    # Config is managed by chezmoi (home/private_dot_config/starship/starship.toml.tmpl)
    if [[ -f "$config_file" ]]; then
        success "Config exists: $config_file (managed by chezmoi)"
    else
        info "Running chezmoi apply to deploy starship config..."
        chezmoi apply ~/.config/starship/starship.toml
        success "Config deployed via chezmoi"
    fi
}

install_nerd_font() {
    info "Checking for Nerd Font..."

    # Starship works best with a Nerd Font for icons
    # Monaspace Neon should work, but we can suggest Nerd Font patched version

    case "$(uname -s)" in
        Darwin)
            if ! brew list --cask font-monaspace-nerd-font &>/dev/null 2>&1; then
                info "Installing Monaspace Nerd Font..."
                brew tap homebrew/cask-fonts 2>/dev/null || true
                brew install --cask font-monaspace-nerd-font || warn "Could not install Nerd Font"
            else
                success "Monaspace Nerd Font already installed"
            fi
            ;;
        Linux)
            info "For best results, install a Nerd Font:"
            echo "  https://www.nerdfonts.com/font-downloads"
            ;;
    esac
}

show_status() {
    echo ""
    echo "Starship Status:"
    echo ""

    if command -v starship &>/dev/null; then
        echo "  Version: $(starship --version | head -1)"
    else
        echo "  Not installed"
    fi

    local config="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
    if [[ -f "$config" ]]; then
        echo "  Config: $config"
        if [[ -L "$config" ]]; then
            echo "  Linked to: $(readlink "$config")"
        fi
    else
        echo "  Config: not found"
    fi
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Setup Starship prompt

Commands:
    install     Install Starship and configure (default)
    config      Setup config file only
    font        Install Nerd Font
    status      Show current status
    help        Show this help

EOF
}

main() {
    case "${1:-install}" in
        install)
            install_starship
            setup_config
            install_nerd_font
            show_status
            success "Starship setup complete! Restart your shell."
            ;;
        config)
            setup_config
            ;;
        font)
            install_nerd_font
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
