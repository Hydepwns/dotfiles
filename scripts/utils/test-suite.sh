#!/bin/bash

# Comprehensive test suite for dotfiles
# This script organizes tests into categories and provides clear reporting

# Don't exit on error, we want to run all tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test with output
run_test() {
    local category="$1"
    local test_name="$2"
    local test_command="$3"
    ((TOTAL_TESTS++))
    echo -n "[$category] $test_name... "
    if eval "$test_command" 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED_TESTS++))
    fi
}

# =============================================================================
# TEST SUITE
# =============================================================================
echo -e "${BLUE}🧪 Dotfiles Test Suite${NC}"
echo "=================================="

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
if grep -q "ohmyzsh = true" chezmoi.toml; then
    run_test "Tools" "Oh My Zsh installation" "test -d ~/.oh-my-zsh"
fi

# Check Homebrew
run_test "Tools" "Homebrew installation" "which brew"

# Check common development tools
run_test "Tools" "git installation" "which git"
run_test "Tools" "vim installation" "which vim"

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
echo -e "${BLUE}Total: $TOTAL_TESTS${NC}"

# Calculate success rate
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "${BLUE}Success Rate: ${SUCCESS_RATE}%${NC}"
fi

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Your dotfiles are working correctly.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please check the output above.${NC}"
    exit 1
fi
