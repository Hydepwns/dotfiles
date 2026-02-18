#!/bin/bash
# Remote bootstrap script - run via: curl -fsSL https://raw.githubusercontent.com/Hydepwns/dotfiles/main/scripts/install/remote-bootstrap.sh | bash
# This script bootstraps a fresh machine with DROO's dotfiles

set -e

REPO="https://github.com/Hydepwns/dotfiles.git"
DOTFILES_DIR="$HOME/.local/share/chezmoi"

# Colors and logging defined inline (can't source logging.sh - repo not cloned yet)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; exit 1; }

header() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}  DROO's Dotfiles - Remote Bootstrap${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
}

# Detect system
detect_system() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    IS_NIXOS=false
    [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release && IS_NIXOS=true

    IS_MAC=false
    [[ "$OS" == "Darwin" ]] && IS_MAC=true

    IS_ARM=false
    [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]] && IS_ARM=true

    info "System: $OS ($ARCH)"
    $IS_NIXOS && info "NixOS detected"
    $IS_MAC && $IS_ARM && info "Apple Silicon detected"
}

# Install Homebrew (macOS)
install_homebrew() {
    if $IS_MAC && ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if $IS_ARM; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        success "Homebrew installed"
    fi
}

# Install Xcode CLI tools (macOS)
install_xcode_tools() {
    if $IS_MAC && ! xcode-select -p &>/dev/null; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install 2>/dev/null || true
        # Wait for installation
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
        success "Xcode tools installed"
    fi
}

# Install chezmoi
install_chezmoi() {
    if command -v chezmoi &>/dev/null; then
        success "chezmoi already installed: $(chezmoi --version | head -1)"
        return 0
    fi

    info "Installing chezmoi..."

    if $IS_MAC; then
        brew install chezmoi
    elif $IS_NIXOS; then
        nix-env -iA nixpkgs.chezmoi
    else
        sh -c "$(curl -fsLS get.chezmoi.io)"
    fi

    success "chezmoi installed"
}

# Install essential tools
install_essentials() {
    info "Installing essential tools..."

    if $IS_MAC; then
        brew install git zsh curl wget jq
    elif $IS_NIXOS; then
        nix-env -iA nixpkgs.git nixpkgs.zsh nixpkgs.curl nixpkgs.wget nixpkgs.jq
    else
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y git zsh curl wget jq
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y git zsh curl wget jq
        elif command -v pacman &>/dev/null; then
            sudo pacman -Syu --noconfirm git zsh curl wget jq
        fi
    fi

    success "Essential tools installed"
}

# Install packages from Brewfile
install_from_brewfile() {
    if $IS_MAC; then
        local brewfile="$DOTFILES_DIR/Brewfile"

        if [[ -f "$brewfile" ]]; then
            info "Installing packages from Brewfile..."
            brew bundle install --file="$brewfile" --no-lock || warn "Some packages may have failed"
            success "Brewfile packages installed"
        else
            warn "Brewfile not found, installing essentials manually..."
            install_secrets_tools_manual
        fi
    else
        warn "Brewfile is macOS only - run 'make setup-secrets' on Linux"
    fi
}

# Manual install if Brewfile not available
install_secrets_tools_manual() {
    info "Installing secrets management tools..."

    if $IS_MAC; then
        # 1Password CLI
        if ! command -v op &>/dev/null; then
            brew install --cask 1password-cli && success "1Password CLI installed"
        fi

        # AWS CLI
        if ! command -v aws &>/dev/null; then
            brew install awscli && success "AWS CLI installed"
        fi

        # Infisical
        if ! command -v infisical &>/dev/null; then
            brew install infisical/get-cli/infisical && success "Infisical installed"
        fi

        # Tailscale
        if ! command -v tailscale &>/dev/null; then
            brew install --cask tailscale && success "Tailscale installed"
        fi

        # Starship
        if ! command -v starship &>/dev/null; then
            brew install starship && success "Starship installed"
        fi
    fi
}

# Install age encryption tool
install_age() {
    if command -v age &>/dev/null; then
        success "age already installed: $(age --version 2>&1 | head -1)"
        return 0
    fi

    info "Installing age..."

    if $IS_MAC; then
        brew install age
    elif $IS_NIXOS; then
        nix-env -iA nixpkgs.age
    else
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y age
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y age
        elif command -v pacman &>/dev/null; then
            sudo pacman -Syu --noconfirm age
        else
            warn "Could not install age automatically"
            return 1
        fi
    fi

    success "age installed"
}

# Retrieve age key from 1Password (needed before chezmoi apply)
setup_age_key() {
    local age_key_path="$HOME/.config/chezmoi/age_key.txt"

    if [[ -f "$age_key_path" ]]; then
        success "Age key already exists"
        return 0
    fi

    if command -v op &>/dev/null && op whoami &>/dev/null 2>&1; then
        info "Retrieving age key from 1Password..."
        local key_content
        key_content=$(op item get "Dotfiles Age Key" --vault "Private" --fields notesPlain 2>/dev/null || true)

        if [[ -n "$key_content" ]]; then
            mkdir -p "$(dirname "$age_key_path")"
            printf '%s\n' "$key_content" > "$age_key_path"
            chmod 600 "$age_key_path"
            success "Age key retrieved from 1Password"
            return 0
        fi
    fi

    warn "Age key not available -- encrypted files will fail to decrypt"
    warn "After signing in to 1Password, run: make age-retrieve"
}

# Initialize dotfiles
init_dotfiles() {
    info "Initializing dotfiles..."

    if [[ -d "$DOTFILES_DIR" ]]; then
        warn "Dotfiles already exist, updating..."
        chezmoi update
    else
        chezmoi init --apply "$REPO"
    fi

    success "Dotfiles initialized"
}

# Set zsh as default shell
setup_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        info "Setting zsh as default shell..."
        chsh -s "$(which zsh)" || warn "Could not change shell automatically"
    fi
    success "Shell configured"
}

# Post-install configuration
post_install() {
    info "Running post-install configuration..."

    # Create AWS config directory
    mkdir -p "$HOME/.aws"
    chmod 700 "$HOME/.aws"

    # Ensure SSH directory exists with correct permissions
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    success "Post-install complete"
}

# Print next steps
print_next_steps() {
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  Bootstrap Complete!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Restart your terminal or run:"
    echo -e "     ${CYAN}exec zsh${NC}"
    echo ""
    echo "  2. Authenticate services:"
    echo -e "     ${CYAN}op signin${NC}              # 1Password"
    echo -e "     ${CYAN}aws configure sso${NC}      # AWS SSO"
    echo -e "     ${CYAN}infisical login${NC}        # Infisical"
    echo -e "     ${CYAN}sudo tailscale up${NC}      # Tailscale"
    echo ""
    echo "  3. Verify installation:"
    echo -e "     ${CYAN}make doctor${NC}            # Health check"
    echo -e "     ${CYAN}make dashboard${NC}         # Service status"
    echo ""
    echo "  4. Age encryption key (if not auto-retrieved):"
    echo -e "     ${CYAN}make age-retrieve${NC}      # Pull key from 1Password"
    echo ""
    echo "  5. Load SSH keys:"
    echo -e "     ${CYAN}ssh-add-keys${NC}           # Add keys to agent"
    echo ""
    echo -e "Documentation: ${BLUE}https://github.com/Hydepwns/dotfiles${NC}"
    echo ""
}

# Main
main() {
    header
    detect_system

    if $IS_MAC; then
        install_xcode_tools
        install_homebrew
    fi

    install_chezmoi
    install_essentials
    install_age
    setup_age_key
    init_dotfiles
    install_from_brewfile
    setup_shell
    post_install
    print_next_steps
}

main "$@"
