#!/bin/bash

# Quick setup script for new machines
# This script installs essential tools and applies dotfiles

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Quick setup for new machine${NC}"
echo "=================================="

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo -e "${GREEN}Detected OS: $OS${NC}"

# Install chezmoi
echo -e "\n${BLUE}Installing chezmoi...${NC}"
if ! command -v chezmoi &> /dev/null; then
    if [[ "$OS" == "macOS" ]]; then
        if command -v brew &> /dev/null; then
            brew install chezmoi
        else
            echo "Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install chezmoi
        fi
    else
        sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$USER"
    fi
else
    echo "chezmoi is already installed"
fi

# Install essential tools based on OS
echo -e "\n${BLUE}Installing essential tools...${NC}"

if [[ "$OS" == "macOS" ]]; then
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install essential tools
    echo "Installing essential tools via Homebrew..."
    brew install \
        git \
        zsh \
        curl \
        wget \
        jq \
        ripgrep \
        fd \
        bat \
        exa \
        fzf \
        tmux \
        neovim
fi

# Initialize dotfiles
echo -e "\n${BLUE}Initializing dotfiles...${NC}"
chezmoi init --apply https://github.com/hydepwns/dotfiles.git

# Set zsh as default shell
echo -e "\n${BLUE}Setting zsh as default shell...${NC}"
if [[ "$SHELL" != *"zsh"* ]]; then
    if command -v zsh &> /dev/null; then
        echo "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
        echo "Please restart your terminal or run 'exec zsh' to switch to zsh"
    else
        echo "Zsh not found, skipping shell change"
    fi
else
    echo "Zsh is already the default shell"
fi

# Run health check
echo -e "\n${BLUE}Running health check...${NC}"
if [[ -f "scripts/utils/health-check.sh" ]]; then
    ./scripts/utils/health-check.sh
else
    echo "Health check script not found"
fi

echo -e "\n${GREEN}✅ Quick setup complete!${NC}"
echo "=================================="
echo "Next steps:"
echo "1. Restart your terminal or run 'exec zsh'"
echo "2. Install additional tools as needed"
echo "3. Customize your configuration" 