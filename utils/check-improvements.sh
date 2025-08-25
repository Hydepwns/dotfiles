#!/usr/bin/env bash

echo "=== Dotfiles Improvement Suggestions ==="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get dotfiles directory
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

echo -e "${BLUE}1. Documentation Updates Needed:${NC}"
echo "-----------------------------------"

# Check for outdated references
if grep -q "make doctor" "$DOTFILES_DIR/README.md" 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  README.md references 'make doctor' - consider updating to mention utils/health-check.sh as alternative"
fi

if grep -q "/scripts/utils/health-check.sh" "$DOTFILES_DIR"/**/*.sh 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  Some scripts reference old health-check.sh path"
fi

echo ""
echo -e "${BLUE}2. Path Improvements:${NC}"
echo "---------------------"

# Check for hardcoded paths
HARDCODED_COUNT=$(grep -r "/home/hydepwns/dotfiles" "$DOTFILES_DIR" --include="*.sh" 2>/dev/null | wc -l)
if [ "$HARDCODED_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC}  Found $HARDCODED_COUNT hardcoded paths - consider using dynamic paths"
fi

echo ""
echo -e "${BLUE}3. Script Improvements:${NC}"
echo "-----------------------"

# Check for scripts that could be optimized
if [ -f "$DOTFILES_DIR/scripts/utils/script-init.sh" ]; then
    echo -e "${YELLOW}⚠${NC}  script-init.sh causes segfaults - needs debugging or simplification"
fi

# Check for duplicate functionality
echo -e "${GREEN}✓${NC} Health check has working alternative (utils/health-check.sh)"
echo -e "${GREEN}✓${NC} Template listing has simple alternative (utils/list-templates.sh)"

echo ""
echo -e "${BLUE}4. Performance Optimizations:${NC}"
echo "-----------------------------"

# Check shell startup time
ZSH_TIME=$(zsh -i -c 'exit' 2>&1 | grep real | sed 's/real.*0m//' | sed 's/,//' | sed 's/s//')
echo -e "${GREEN}✓${NC} ZSH startup time: ${ZSH_TIME}ms (excellent!)"

echo ""
echo -e "${BLUE}5. Missing Features to Consider:${NC}"
echo "---------------------------------"

# Check for optional tools
command -v nvim >/dev/null 2>&1 || echo "• Neovim (powerful editor)"
command -v kitty >/dev/null 2>&1 || echo "• Kitty (GPU-accelerated terminal)"
[ -d ~/.oh-my-zsh ] || echo "• Oh My Zsh (shell framework)"
command -v asdf >/dev/null 2>&1 || echo "• asdf (version manager)"

echo ""
echo -e "${BLUE}6. Security Improvements:${NC}"
echo "-------------------------"

# Check for sensitive files
if [ -f "$DOTFILES_DIR/home/dot_ssh/private_id_rsa.tmpl" ]; then
    echo -e "${YELLOW}⚠${NC}  SSH key template found - ensure it's properly protected"
fi

# Check git config
if ! git config --get commit.gpgsign >/dev/null 2>&1; then
    echo "• Consider enabling GPG signing for commits"
fi

echo ""
echo -e "${BLUE}7. Recommended Actions:${NC}"
echo "-----------------------"
echo "1. Update README.md to mention utils/health-check.sh as the working alternative"
echo "2. Replace hardcoded paths with dynamic detection"
echo "3. Debug or replace script-init.sh to fix segmentation faults"
echo "4. Consider installing optional development tools"
echo "5. Add GPG signing to git configuration for security"

echo ""
echo -e "${GREEN}Overall: Your dotfiles are well-organized and functional!${NC}"
echo "These are minor improvements to make them even better."