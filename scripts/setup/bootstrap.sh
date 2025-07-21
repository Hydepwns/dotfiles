#!/bin/bash
# Bootstrap script for DROO's dotfiles
# This script can be run on any fresh system to set up the dotfiles

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../utils/colors.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/../utils/colors.sh"
else
    echo "Warning: colors.sh not found, using fallback colors"
    # Fallback color definitions
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
fi

echo "🚀 Bootstrap script for DROO's dotfiles"
echo "========================================"

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

print_status "INFO" "Detected OS: $OS ($ARCH)"

# Detect NixOS
is_nixos() {
    [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release
}

# Install chezmoi based on OS
install_chezmoi() {
    if command -v chezmoi &> /dev/null; then
        print_status "OK" "chezmoi already installed ($(chezmoi --version))"
        return 0
    fi

    print_status "INFO" "Installing chezmoi..."

    case "$OS" in
        "Darwin")
            if ! command -v brew &> /dev/null; then
                print_status "INFO" "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                # Add Homebrew to PATH for Apple Silicon
                if [[ "$ARCH" == "arm64" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            fi
            brew install chezmoi
            ;;
        "Linux")
            if is_nixos; then
                print_status "INFO" "Detected NixOS - installing chezmoi via nix-env..."
                nix-env -iA nixpkgs.chezmoi
            else
                sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$USER"
            fi
            ;;
        *)
            print_status "ERROR" "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

# Install basic dependencies
install_dependencies() {
    print_status "INFO" "Installing basic dependencies..."

    case "$OS" in
        "Darwin")
            # Install Xcode Command Line Tools if not present
            if ! xcode-select -p &> /dev/null; then
                print_status "INFO" "Installing Xcode Command Line Tools..."
                xcode-select --install
            fi

            # Install basic tools
            brew install git zsh curl
            ;;
        "Linux")
            if is_nixos; then
                print_status "INFO" "Detected NixOS - installing dependencies via nix-env..."
                nix-env -iA nixpkgs.git nixpkgs.zsh nixpkgs.curl
            else
                # Detect package manager
                if command -v apt &> /dev/null; then
                    sudo apt update
                    sudo apt install -y git zsh curl
                elif command -v yum &> /dev/null; then
                    sudo yum update -y
                    sudo yum install -y git zsh curl
                elif command -v pacman &> /dev/null; then
                    sudo pacman -Syu --noconfirm git zsh curl
                else
                    print_status "WARN" "Unknown package manager, please install git, zsh, and curl manually"
                fi
            fi
            ;;
    esac
}

# Initialize dotfiles
initialize_dotfiles() {
    print_status "INFO" "Initializing dotfiles..."

    # Check if dotfiles are already initialized
    if [[ -d "$HOME/.local/share/chezmoi" ]]; then
        print_status "WARN" "Dotfiles already initialized. Updating..."
        chezmoi update
    else
        chezmoi init --apply https://github.com/hydepwns/dotfiles.git
    fi
}

# Set up shell
setup_shell() {
    print_status "INFO" "Setting up shell..."

    # Check if zsh is available
    if ! command -v zsh &> /dev/null; then
        print_status "ERROR" "Zsh not found. Please install zsh first."
        return 1
    fi

    # Set zsh as default shell if not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        print_status "INFO" "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
        print_status "WARN" "Please restart your terminal or run 'exec zsh' to use the new shell"
    else
        print_status "OK" "Zsh is already the default shell"
    fi
}

# Post-installation setup
post_install() {
    print_status "INFO" "Running post-installation setup..."

    # Source the new zshrc to get all functions (only if running in zsh)
    if [[ -n "$ZSH_VERSION" ]] && [[ -f "$HOME/.zshrc" ]]; then
        # shellcheck disable=SC1091
        source "$HOME/.zshrc"
    fi

    # Run health check
    if [[ -f "$HOME/.local/share/chezmoi/scripts/utils/health-check.sh" ]]; then
        print_status "INFO" "Running health check..."
        "$HOME/.local/share/chezmoi/scripts/utils/health-check.sh"
    fi
}

# Main execution
main() {
    install_chezmoi
    install_dependencies
    initialize_dotfiles
    setup_shell
    post_install

    echo ""
    echo "✅ Bootstrap complete!"
    echo "========================================"
    echo "Next steps:"
    echo "1. Restart your terminal or run 'exec zsh'"
    echo "2. Run 'make doctor' to verify the installation"
    echo "3. Customize your configuration as needed"
    echo ""
    echo "For help, see: https://github.com/hydepwns/dotfiles"
}

# Run main function
main "$@"
