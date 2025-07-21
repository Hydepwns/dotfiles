#!/bin/bash
# NixOS-specific setup script for DROO's dotfiles
set -e

echo "🚀 NixOS setup for DROO's dotfiles..."
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK") echo -e "${GREEN}✓${NC} $message" ;;
        "WARN") echo -e "${YELLOW}⚠${NC} $message" ;;
        "ERROR") echo -e "${RED}✗${NC} $message" ;;
        "INFO") echo -e "${BLUE}ℹ${NC} $message" ;;
    esac
}

# Verify we're on NixOS
if [[ ! -f /etc/os-release ]] || ! grep -q "ID=nixos" /etc/os-release; then
    print_status "ERROR" "This script is designed for NixOS only"
    exit 1
fi

print_status "OK" "NixOS detected"

# Install chezmoi via nix-env if not present
if ! command -v chezmoi &> /dev/null; then
    print_status "INFO" "Installing chezmoi..."
    
    # Try different installation methods
    install_success=false
    
    # Method 1: Try nixos.chezmoi (classic channels)
    if nix-env -iA nixos.chezmoi 2>/dev/null; then
        print_status "OK" "chezmoi installed via nix-env (nixos.chezmoi)"
        install_success=true
    # Method 2: Try nixpkgs.chezmoi (if nixpkgs channel is available)
    elif nix-env -iA nixpkgs.chezmoi 2>/dev/null; then
        print_status "OK" "chezmoi installed via nix-env (nixpkgs.chezmoi)"
        install_success=true
    # Method 3: Try flakes (if enabled)
    elif command -v nix &> /dev/null && nix profile install nixpkgs#chezmoi 2>/dev/null; then
        print_status "OK" "chezmoi installed via nix flakes"
        install_success=true
    # Method 4: Try direct nix-env install
    elif nix-env -i chezmoi 2>/dev/null; then
        print_status "OK" "chezmoi installed via direct nix-env"
        install_success=true
    else
        print_status "ERROR" "Failed to install chezmoi via nix-env or flakes"
        print_status "INFO" "Trying alternative installation methods..."
        
        # Method 5: Try curl installation as fallback
        if sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$USER" 2>/dev/null; then
            print_status "OK" "chezmoi installed via official installer"
            install_success=true
        else
            print_status "ERROR" "All installation methods failed"
            print_status "INFO" "Please install chezmoi manually:"
            echo "  - Add nixpkgs channel: nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs"
            echo "  - Update channels: nix-channel --update"
            echo "  - Install: nix-env -iA nixpkgs.chezmoi"
            echo "  - Or use flakes: nix profile install nixpkgs#chezmoi"
            exit 1
        fi
    fi
    
    if [[ "$install_success" == "true" ]]; then
        print_status "OK" "chezmoi installed successfully"
    fi
else
    print_status "OK" "chezmoi already installed ($(chezmoi --version))"
fi

# Install basic dependencies if not present
install_deps() {
    local deps=("git" "zsh" "curl")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_status "INFO" "Installing missing dependencies: ${missing_deps[*]}"
        nix-env -iA "nixpkgs.${missing_deps[*]}"
        print_status "OK" "Dependencies installed"
    else
        print_status "OK" "All dependencies already installed"
    fi
}

install_deps

# Initialize and apply dotfiles
print_status "INFO" "Initializing dotfiles..."
chezmoi init --apply https://github.com/hydepwns/dotfiles.git

# Set zsh as default shell if not already
if [[ "$SHELL" != *"zsh"* ]]; then
    print_status "INFO" "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    print_status "WARN" "Please restart your terminal or run 'exec zsh' to use the new shell"
else
    print_status "OK" "Zsh is already the default shell"
fi

echo ""
echo "✅ NixOS setup complete!"
echo "========================"
echo "Next steps:"
echo "1. Restart your terminal or run 'exec zsh'"
echo "2. Run 'make doctor' to verify the installation"
echo "3. Customize your configuration as needed"
echo ""
echo "For help, see: https://github.com/hydepwns/dotfiles" 