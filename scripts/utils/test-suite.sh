#!/bin/bash

# Comprehensive test suite for dotfiles
# This script organizes tests into categories and provides clear reporting

# Don't exit on error, we want to run all tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Platform detection
OS="$(uname -s)"
IS_MACOS=false
IS_LINUX=false
IS_NIXOS=false

case "$OS" in
    Darwin)
        IS_MACOS=true
        ;;
    Linux)
        IS_LINUX=true
        # Check if NixOS
        if [ -f /etc/os-release ] && grep -q "NixOS" /etc/os-release; then
            IS_NIXOS=true
        fi
        ;;
esac

# Function to run a test
run_test() {
    local category="$1"
    local test_name="$2"
    local test_command="$3"
    ((TOTAL_TESTS++))
    echo -n "[$category] $test_name... "
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED_TESTS++))
    fi
}

# Function to skip a test
skip_test() {
    local category="$1"
    local test_name="$2"
    local reason="$3"
    ((TOTAL_TESTS++))
    ((SKIPPED_TESTS++))
    echo -e "[$category] $test_name... ${CYAN}⊘ SKIP${NC} ($reason)"
}

# Pre-flight check
preflight_check() {
    echo -e "${BLUE}🔍 Pre-flight Check${NC}"
    echo "=================================="
    
    # Check if chezmoi has been applied
    if [ ! -d ~/.zsh ] && [ -d home/dot_zsh ]; then
        echo -e "${YELLOW}⚠️  Warning: Dotfiles not applied yet!${NC}"
        echo -e "Run: ${GREEN}chezmoi apply${NC} to apply your dotfiles"
        echo ""
    fi
    
    # Platform info
    echo -e "Platform: ${CYAN}$OS${NC}"
    if $IS_NIXOS; then
        echo -e "Distribution: ${CYAN}NixOS${NC}"
    fi
    echo ""
}

# =============================================================================
# TEST SUITE
# =============================================================================
echo -e "${BLUE}🧪 Dotfiles Test Suite${NC}"
echo "=================================="

# Run pre-flight check
preflight_check

# =============================================================================
# CORE INFRASTRUCTURE TESTS
# =============================================================================
echo -e "\n${YELLOW}📋 Core Infrastructure Tests${NC}"

run_test "Core" "chezmoi installation" "which chezmoi"
run_test "Core" "git repository" "test -d .git"
run_test "Core" "chezmoi configuration" "test -f chezmoi.toml"
run_test "Core" "Makefile exists" "test -f Makefile"

# =============================================================================
# SHELL CONFIGURATION TESTS
# =============================================================================
echo -e "\n${YELLOW}🐚 Shell Configuration Tests${NC}"

run_test "Shell" "zshrc existence" "test -f ~/.zshrc"
run_test "Shell" "zshrc syntax" "zsh -n ~/.zshrc"
run_test "Shell" "modular zsh directory" "test -d ~/.zsh"
run_test "Shell" "modules.zsh existence" "test -f ~/.zsh/modules.zsh"
run_test "Shell" "modules.zsh syntax" "zsh -n ~/.zsh/modules.zsh"

# =============================================================================
# TOOL INSTALLATION TESTS
# =============================================================================
echo -e "\n${YELLOW}🛠️  Tool Installation Tests${NC}"

# Check Oh My Zsh if enabled
if grep -q "ohmyzsh = true" chezmoi.toml 2>/dev/null; then
    run_test "Tools" "Oh My Zsh installation" "test -d ~/.oh-my-zsh"
else
    skip_test "Tools" "Oh My Zsh installation" "not enabled in config"
fi

# Check package managers based on platform
if $IS_MACOS; then
    run_test "Tools" "Homebrew installation" "which brew"
elif $IS_NIXOS; then
    skip_test "Tools" "Homebrew installation" "NixOS uses Nix"
    run_test "Tools" "Nix installation" "which nix"
else
    # Generic Linux - could have either
    if which brew >/dev/null 2>&1; then
        run_test "Tools" "Homebrew installation" "which brew"
    else
        skip_test "Tools" "Homebrew installation" "not installed"
    fi
fi

# Check common development tools
run_test "Tools" "git installation" "which git"

# Vim/Neovim check
if which nvim >/dev/null 2>&1; then
    run_test "Tools" "neovim installation" "which nvim"
elif which vim >/dev/null 2>&1; then
    run_test "Tools" "vim installation" "which vim"
else
    run_test "Tools" "vim/neovim installation" "which vim || which nvim"
fi

# =============================================================================
# CONFIGURATION VALIDATION TESTS
# =============================================================================
echo -e "\n${YELLOW}⚙️  Configuration Validation Tests${NC}"

run_test "Config" "chezmoi verify" "chezmoi verify"
run_test "Config" "no uncommitted changes" "git diff --quiet"
run_test "Config" "managed files exist" "chezmoi managed | head -5 | xargs -I {} test -e {}"

# =============================================================================
# INTEGRATION TESTS
# =============================================================================
echo -e "\n${YELLOW}🔗 Integration Tests${NC}"

run_test "Integration" "zsh configuration syntax" "zsh -n ~/.zshrc"

# =============================================================================
# SECURITY TESTS
# =============================================================================
echo -e "\n${YELLOW}🔒 Security Tests${NC}"

run_test "Security" "no sensitive files in repo" "! git ls-files | grep -E '\.(key|pem|p12|pfx)$'"
run_test "Security" "SSH config exists" "test -f ~/.ssh/config"

# =============================================================================
# TEST SUMMARY
# =============================================================================
echo -e "\n${BLUE}📊 Test Summary${NC}"
echo "=================================="
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo -e "${CYAN}Skipped: $SKIPPED_TESTS${NC}"
echo -e "${BLUE}Total: $TOTAL_TESTS${NC}"

# Calculate success rate (excluding skipped tests)
if [ $((TOTAL_TESTS - SKIPPED_TESTS)) -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / (TOTAL_TESTS - SKIPPED_TESTS)))
    echo -e "${BLUE}Success Rate: ${SUCCESS_RATE}% (excluding skipped)${NC}"
fi

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Your dotfiles are working correctly.${NC}"
    if [ $SKIPPED_TESTS -gt 0 ]; then
        echo -e "${CYAN}Note: $SKIPPED_TESTS tests were skipped (platform-specific or not configured)${NC}"
    fi
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please check the output above.${NC}"
    if [ ! -d ~/.zsh ] && [ -d home/dot_zsh ]; then
        echo -e "\n${YELLOW}💡 Tip: Run 'chezmoi apply' to apply your dotfiles first${NC}"
    fi
    exit 1
fi
