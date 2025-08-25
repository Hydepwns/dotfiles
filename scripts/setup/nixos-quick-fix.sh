#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1 | xargs dirname)"
source "$UTILS_DIR/script-init.sh"


# Quick fix script for common NixOS dotfiles issues
# This script addresses common problems when setting up dotfiles on NixOS

# Source shared utilities

echo -e "${BLUE}NixOS Dotfiles Quick Fix${NC}"
echo "=================================="
echo ""

# Function to fix an issue
fix_issue() {
    local description="$1"
    local command="$2"
    
    echo -e "${YELLOW}>${NC} $description..."
    if eval "$command"; then
        echo -e "  ${GREEN}Fixed${NC}"
        return 0
    else
        echo -e "  ${RED}Failed${NC}"
        return 1
    fi
}

# Check if we're on NixOS
if [ ! -f /etc/os-release ] || ! grep -q "NixOS" /etc/os-release; then
    echo -e "${YELLOW}Warning: This script is designed for NixOS${NC}"
    echo "Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit $EXIT_SUCCESS
    fi
fi

echo -e "${CYAN}Checking and fixing common issues...${NC}"
echo ""

# Fix 1: Remove broken Home-Manager symlinks
if [ -L "$HOME/.profile" ] && ! [ -e "$HOME/.profile" ]; then
    fix_issue "Removing broken .profile symlink" "rm '$HOME/.profile'"
    fix_issue "Creating temporary .profile" "echo '# Profile managed by chezmoi' > '$HOME/.profile'"
fi

# Fix 2: Install essential tools via Nix
echo ""
echo -e "${CYAN}Installing essential tools...${NC}"

if ! has_command zsh; then
    fix_issue "Installing zsh" "nix-env -iA nixos.zsh"
fi

if ! has_command make; then
    fix_issue "Installing make" "nix-env -iA nixos.gnumake"
fi

if ! has_command nvim && ! has_command vim; then
    echo -e "${YELLOW}>${NC} Would you like to install neovim? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        fix_issue "Installing neovim" "nix-env -iA nixos.neovim"
    fi
fi

# Fix 3: Apply chezmoi dotfiles
echo ""
echo -e "${CYAN}Applying dotfiles...${NC}"

if has_command chezmoi; then
    # Check if dotfiles haven't been applied
    if [ ! -d "$HOME/.zsh" ] || [ ! -f "$HOME/.zshrc" ] || [ $(wc -l < "$HOME/.zshrc" 2>/dev/null || echo 0) -lt 5 ]; then
        echo -e "${YELLOW}>${NC} Dotfiles appear to be missing or incomplete"
        echo "Apply chezmoi dotfiles now? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            fix_issue "Applying chezmoi dotfiles" "chezmoi apply -v"
        fi
    else
        echo -e "  ${GREEN}Dotfiles already applied${NC}"
    fi
else
    echo -e "  ${RED}chezmoi not found${NC}"
    echo -e "  ${YELLOW}> Install chezmoi first${NC}"
fi

# Fix 4: Install Oh My Zsh if configured
echo ""
echo -e "${CYAN}Optional components...${NC}"

if grep -q "ohmyzsh = true" chezmoi.toml 2>/dev/null && [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}>${NC} Oh My Zsh is configured but not installed"
    echo "Install Oh My Zsh now? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        fix_issue "Installing Oh My Zsh" \
            'safe_download_execute "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "Oh My Zsh installation"'
    fi
fi

# Fix 5: Set ZSH as default shell
echo ""
echo -e "${CYAN}Shell configuration...${NC}"

if has_command zsh; then
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        echo -e "${YELLOW}>${NC} Current shell is $CURRENT_SHELL, not zsh"
        echo "Set zsh as default shell? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            ZSH_PATH=$(command -v zsh)
            fix_issue "Adding zsh to /etc/shells" "echo $ZSH_PATH | sudo tee -a /etc/shells"
            fix_issue "Setting zsh as default shell" "chsh -s $ZSH_PATH"
            echo -e "  ${YELLOW}> You'll need to log out and back in for this to take effect${NC}"
        fi
    else
        echo -e "  ${GREEN}ZSH is already the default shell${NC}"
    fi
fi

# Summary
echo ""
echo "=================================="
echo -e "${BLUE}Quick Fix Complete${NC}"
echo "=================================="

# Run verification
echo ""
echo -e "${CYAN}Running setup verification...${NC}"
echo ""

if [ -f scripts/utils/verify-setup.sh ]; then
    bash scripts/utils/verify-setup.sh
else
    echo -e "${YELLOW}Warning: Verification script not found${NC}"
fi

echo ""
echo -e "${GREEN}Quick fix complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. If you changed your shell, log out and back in"
echo "  2. Run: ${CYAN}make test${NC} to verify everything works"
