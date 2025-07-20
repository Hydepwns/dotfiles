#!/bin/bash

# Health check script for dotfiles
# This script verifies that all components are properly installed and configured

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/colors.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/colors.sh"
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

echo "🔍 Running dotfiles health check..."
echo "=================================="

# Check chezmoi installation
echo -e "\n${BLUE}Checking chezmoi...${NC}"
if command -v chezmoi &> /dev/null; then
    print_status "OK" "chezmoi is installed ($(chezmoi --version))"
else
    print_status "ERROR" "chezmoi is not installed"
fi

# Check git configuration
echo -e "\n${BLUE}Checking git configuration...${NC}"
if git config --global --get user.name &> /dev/null; then
    print_status "OK" "Git user.name is set: $(git config --global --get user.name)"
else
    print_status "WARN" "Git user.name is not set"
fi

if git config --global --get user.email &> /dev/null; then
    print_status "OK" "Git user.email is set: $(git config --global --get user.email)"
else
    print_status "WARN" "Git user.email is not set"
fi

# Check shell configuration
echo -e "\n${BLUE}Checking shell configuration...${NC}"
print_status "INFO" "Current shell: $SHELL"

if command -v zsh &> /dev/null; then
    print_status "OK" "Zsh is installed ($(zsh --version | head -n1))"
else
    print_status "WARN" "Zsh is not installed"
fi

# Check if zsh is the default shell
if [[ "$SHELL" == *"zsh"* ]]; then
    print_status "OK" "Zsh is the default shell"
else
    print_status "WARN" "Zsh is not the default shell (current: $SHELL)"
fi

# Check development tools
echo -e "\n${BLUE}Checking development tools...${NC}"

# Check Homebrew (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
        print_status "OK" "Homebrew is installed"
    else
        print_status "WARN" "Homebrew is not installed"
    fi
fi

# Check Node.js
if command -v node &> /dev/null; then
    print_status "OK" "Node.js is installed ($(node --version))"
else
    print_status "WARN" "Node.js is not installed"
fi

# Check Rust
if command -v rustc &> /dev/null; then
    print_status "OK" "Rust is installed ($(rustc --version))"
else
    print_status "WARN" "Rust is not installed"
fi

# Check Python
if command -v python3 &> /dev/null; then
    print_status "OK" "Python 3 is installed ($(python3 --version))"
else
    print_status "WARN" "Python 3 is not installed"
fi

# Check asdf
if command -v asdf &> /dev/null; then
    print_status "OK" "asdf is installed"
else
    print_status "INFO" "asdf is not installed"
fi

# Check NVM
if command -v nvm &> /dev/null; then
    print_status "OK" "NVM is installed"
elif [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    print_status "OK" "NVM is installed but not loaded"
else
    print_status "INFO" "NVM is not installed"
fi

# Check rbenv
if command -v rbenv &> /dev/null; then
    print_status "OK" "rbenv is installed"
else
    print_status "INFO" "rbenv is not installed"
fi

# Check Elixir
if command -v elixir &> /dev/null; then
    print_status "OK" "Elixir is installed ($(elixir --version | head -n1))"
else
    print_status "INFO" "Elixir is not installed"
fi

# Check Lua
if command -v lua &> /dev/null; then
    print_status "OK" "Lua is installed ($(lua -v))"
else
    print_status "INFO" "Lua is not installed"
fi

# Check direnv
if command -v direnv &> /dev/null; then
    print_status "OK" "direnv is installed"
else
    print_status "INFO" "direnv is not installed"
fi

# Check Nix
if command -v nix &> /dev/null; then
    print_status "OK" "Nix is installed"
else
    print_status "INFO" "Nix is not installed"
fi

# Check Neovim
if command -v nvim &> /dev/null; then
    print_status "OK" "Neovim is installed ($(nvim --version | head -n1))"
else
    print_status "INFO" "Neovim is not installed"
fi

# Check chezmoi data
echo -e "\n${BLUE}Checking chezmoi configuration...${NC}"
if [[ -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
    print_status "OK" "chezmoi configuration exists"
else
    print_status "WARN" "chezmoi configuration not found"
fi

# Check if dotfiles are applied
if chezmoi status &> /dev/null; then
    print_status "OK" "Dotfiles are properly applied"
else
    print_status "WARN" "Dotfiles may not be properly applied"
fi

# Add these checks
check_ssh_keys() {
    if [[ -f ~/.ssh/id_rsa ]]; then
        print_status "OK" "SSH private key exists"
    else
        print_status "WARN" "SSH private key not found"
    fi
}

check_github_token() {
    if [[ -n "$GITHUB_TOKEN" ]]; then
        print_status "OK" "GitHub token is set"
    else
        print_status "WARN" "GitHub token not found"
    fi
}

echo -e "\n${BLUE}Health check complete!${NC}"
echo "==================================" 