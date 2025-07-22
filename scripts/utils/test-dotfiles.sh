#!/bin/bash

# Test script for dotfiles validation
# This script tests various aspects of the dotfiles configuration

set -e

echo "🧪 Testing dotfiles configuration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing $test_name... "

    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo -e "${RED}Command: $test_command${NC}"
        echo -e "${RED}Output: $(eval "$test_command")${NC}"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Check if chezmoi is installed
run_test "chezmoi installation" "which chezmoi"

# Test 2: Check if zshrc exists
run_test "zshrc existence" "test -f ~/.zshrc"

# Test 3: Check zshrc syntax
run_test "zshrc syntax" "zsh -n ~/.zshrc"

# Test 4: Check if Oh My Zsh is installed (if enabled)
if grep -q "ohmyzsh = true" chezmoi.toml; then
    run_test "Oh My Zsh installation" "test -d ~/.oh-my-zsh"
fi

# Test 5: Check if modular zsh directory exists
run_test "modular zsh directory" "test -d ~/.zsh"

# Test 6: Check if modules.zsh exists
run_test "modules.zsh existence" "test -f ~/.zsh/modules.zsh"

# Test 7: Check modules.zsh syntax
run_test "modules.zsh syntax" "zsh -n ~/.zsh/modules.zsh"

# Test 8: Check if chezmoi configuration is valid
run_test "chezmoi configuration" "chezmoi verify"

# Test 9: Check if all managed files exist
run_test "managed files existence" "chezmoi managed | xargs -I {} test -e {}"

# Test 10: Check if there are any uncommitted changes
run_test "git status clean" "git diff --quiet"

echo ""
echo "📊 Test Results:"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please check the output above.${NC}"
    exit 1
fi
