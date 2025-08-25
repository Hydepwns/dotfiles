#!/usr/bin/env bash

# Quick fix script for common NixOS dotfiles issues
# This script addresses common problems when setting up dotfiles on NixOS

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 NixOS Dotfiles Quick Fix${NC}"
echo "=================================="
echo ""

# Function to fix an issue
fix_issue() {
    local description="$1"
    local command="$2"
    
    echo -e "${YELLOW}→${NC} $description..."
    if eval "$command"; then
        echo -e "  ${GREEN}✓ Fixed${NC}"
        return 0
    else
        echo -e "  ${RED}✗ Failed${NC}"
        return 1
    fi
}

# Check if we're on NixOS
if [ ! -f /etc/os-release ] || ! grep -q "NixOS" /etc/os-release; then
    echo -e "${YELLOW}⚠️  Warning: This script is designed for NixOS${NC}"
    echo "Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo -e "${CYAN}📋 Checking and fixing common issues...${NC}"
echo ""

# Fix 1: Remove broken Home-Manager symlinks
if [ -L ~/.profile ] && ! [ -e ~/.profile ]; then
    fix_issue "Removing broken .profile symlink" "rm ~/.profile"
    fix_issue "Creating temporary .profile" "echo '# Profile managed by chezmoi' > ~/.profile"
fi

# Fix 2: Install essential tools via Nix
echo ""
echo -e "${CYAN}📦 Installing essential tools...${NC}"

if ! which zsh >/dev/null 2>&1; then
    fix_issue "Installing zsh" "nix-env -iA nixpkgs.zsh"
fi

if ! which make >/dev/null 2>&1; then
    fix_issue "Installing make" "nix-env -iA nixpkgs.gnumake"
fi

if ! which nvim >/dev/null 2>&1 && ! which vim >/dev/null 2>&1; then
    echo -e "${YELLOW}→${NC} Would you like to install neovim? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        fix_issue "Installing neovim" "nix-env -iA nixpkgs.neovim"
    fi
fi

# Fix 3: Apply chezmoi dotfiles
echo ""
echo -e "${CYAN}🏠 Applying dotfiles...${NC}"

if which chezmoi >/dev/null 2>&1; then
    # Check if dotfiles haven't been applied
    if [ ! -d ~/.zsh ] || [ ! -f ~/.zshrc ] || [ $(wc -l < ~/.zshrc 2>/dev/null || echo 0) -lt 5 ]; then
        echo -e "${YELLOW}→${NC} Dotfiles appear to be missing or incomplete"
        echo "Apply chezmoi dotfiles now? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            fix_issue "Applying chezmoi dotfiles" "chezmoi apply -v"
        fi
    else
        echo -e "  ${GREEN}✓ Dotfiles already applied${NC}"
    fi
else
    echo -e "  ${RED}✗ chezmoi not found${NC}"
    echo -e "  ${YELLOW}→ Install chezmoi first${NC}"
fi

# Fix 4: Install Oh My Zsh if configured
echo ""
echo -e "${CYAN}🎨 Optional components...${NC}"

if grep -q "ohmyzsh = true" chezmoi.toml 2>/dev/null && [ ! -d ~/.oh-my-zsh ]; then
    echo -e "${YELLOW}→${NC} Oh My Zsh is configured but not installed"
    echo "Install Oh My Zsh now? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        fix_issue "Installing Oh My Zsh" \
            'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    fi
fi

# Fix 5: Set ZSH as default shell
echo ""
echo -e "${CYAN}🐚 Shell configuration...${NC}"

if which zsh >/dev/null 2>&1; then
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        echo -e "${YELLOW}→${NC} Current shell is $CURRENT_SHELL, not zsh"
        echo "Set zsh as default shell? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            ZSH_PATH=$(which zsh)
            fix_issue "Adding zsh to /etc/shells" "echo $ZSH_PATH | sudo tee -a /etc/shells"
            fix_issue "Setting zsh as default shell" "chsh -s $ZSH_PATH"
            echo -e "  ${YELLOW}→ You'll need to log out and back in for this to take effect${NC}"
        fi
    else
        echo -e "  ${GREEN}✓ ZSH is already the default shell${NC}"
    fi
fi

# Summary
echo ""
echo "=================================="
echo -e "${BLUE}📊 Quick Fix Complete${NC}"
echo "=================================="

# Run verification
echo ""
echo -e "${CYAN}Running setup verification...${NC}"
echo ""

if [ -f scripts/utils/verify-setup.sh ]; then
    bash scripts/utils/verify-setup.sh
else
    echo -e "${YELLOW}⚠️  Verification script not found${NC}"
fi

echo ""
echo -e "${GREEN}✅ Quick fix complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. If you changed your shell, log out and back in"
echo "  2. Run: ${CYAN}make test${NC} to verify everything works"
echo "  3. Run: ${CYAN}make doctor${NC} for a health check"