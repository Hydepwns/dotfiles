#!/usr/bin/env bash

echo "=== Dotfiles Functionality Test Suite ==="
echo ""

# Dynamic path detection
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNING=0

# Test function
run_test() {
    local test_name="$1"
    local test_cmd="$2"

    echo -n "Testing $test_name... "

    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}+ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}- FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Warning test function
check_warning() {
    local test_name="$1"
    local test_cmd="$2"

    echo -n "Checking $test_name... "

    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}+ OK${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}! WARNING${NC}"
        ((TESTS_WARNING++))
    fi
}

echo "1. Core Tools"
echo "-------------"
run_test "chezmoi installed" "command -v chezmoi"
run_test "git installed" "command -v git"
run_test "zsh installed" "command -v zsh"
run_test "make installed" "command -v make"

echo ""
echo "2. Configuration Files"
echo "----------------------"
run_test "Git config exists" "test -f ~/.gitconfig"
run_test "Git user configured" "git config user.name"
run_test "Git email configured" "git config user.email"
run_test "ZSH config exists" "test -f ~/.zshrc"
run_test "Chezmoi config exists" "test -f ~/.config/chezmoi/chezmoi.toml"

echo ""
echo "3. Chezmoi Status"
echo "-----------------"
run_test "Chezmoi installed" "chezmoi --version >/dev/null 2>&1"
run_test "Chezmoi source dir" "test -d ~/.local/share/chezmoi"
run_test "Chezmoi configured" "test -f ~/.config/chezmoi/chezmoi.toml"

echo ""
echo "4. Directory Structure"
echo "----------------------"
run_test "Scripts directory" "test -d $DOTFILES_DIR/scripts"
run_test "Config directory" "test -d $DOTFILES_DIR/config"
run_test "Docs directory" "test -d $DOTFILES_DIR/docs"
run_test "Utils directory" "test -d $DOTFILES_DIR/utils"
run_test "Home templates" "test -d $DOTFILES_DIR/home"

echo ""
echo "5. Shell Performance"
echo "--------------------"
# Measure ZSH startup time in milliseconds
ZSH_TIME_MS=$(( $(zsh -i -c 'exit' 2>&1 | grep real | sed 's/real.*0m//' | sed 's/,//' | sed 's/s//') ))
echo "ZSH startup time: ${ZSH_TIME_MS}ms"
run_test "ZSH fast startup (<100ms)" "[ ${ZSH_TIME_MS:-999} -lt 100 ]"

echo ""
echo "6. Makefile Targets"
echo "-------------------"
run_test "Makefile exists" "test -f Makefile"
run_test "Help target" "make help >/dev/null 2>&1"
check_warning "Doctor target" "make doctor 2>/dev/null"
run_test "Backup target" "make backup >/dev/null 2>&1"

echo ""
echo "7. Utility Scripts"
echo "------------------"
run_test "Health check script" "test -x $DOTFILES_DIR/utils/health-check.sh"
run_test "Template list script" "test -x $DOTFILES_DIR/utils/list-templates.sh"
run_test "Health check runs" "bash $DOTFILES_DIR/utils/health-check.sh >/dev/null 2>&1"

echo ""
echo "8. Git Repository"
echo "-----------------"
run_test "Git repo initialized" "git rev-parse --git-dir"
run_test "Git remote configured" "git remote -v | grep -q origin"
run_test "Main branch exists" "git show-ref --verify --quiet refs/heads/main"

echo ""
echo "9. Optional Features"
echo "--------------------"
check_warning "Neovim installed" "command -v nvim"
check_warning "Kitty installed" "command -v kitty"
check_warning "Oh My Zsh" "test -d ~/.oh-my-zsh"
check_warning "asdf installed" "command -v asdf"

echo ""
echo "=========================="
echo "Test Results Summary"
echo "=========================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${YELLOW}Warnings: $TESTS_WARNING${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}+ All critical tests passed!${NC}"
    exit 0
else
    echo -e "${RED}- Some tests failed. Please review.${NC}"
    exit 1
fi
