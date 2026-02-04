#!/usr/bin/env bash

# Use simple script initialization (no segfaults!)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/simple-init.sh"

# Comprehensive test suite for dotfiles
# This script organizes tests into categories and provides clear reporting

# Don't exit on error, we want to run all tests
set +e

# Simple utilities (no dependencies)
log_info() { echo -e "${BLUE:-}[INFO]${NC:-} $1"; }
log_success() { echo -e "${GREEN:-}[SUCCESS]${NC:-} $1"; }
log_error() { echo -e "${RED:-}[ERROR]${NC:-} $1" >&2; }
log_warning() { echo -e "${YELLOW:-}[WARNING]${NC:-} $1"; }

# Simple utility functions
file_exists() { test -f "$1"; }
dir_exists() { test -d "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
# shellcheck source=platform.sh
source "$SCRIPT_DIR/platform.sh" 2>/dev/null || {
    # Fallback platform detection
    OS="$(uname -s)"
    IS_MACOS=false
    # shellcheck disable=SC2034
    IS_LINUX=false
    IS_NIXOS=false
    case "$OS" in
        Darwin) IS_MACOS=true ;;
        Linux)
            # shellcheck disable=SC2034
            IS_LINUX=true
            [ -f /etc/os-release ] && grep -q "NixOS" /etc/os-release && IS_NIXOS=true
            ;;
    esac
}

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Function to run a test
run_test() {
    local category="$1"
    local test_name="$2"
    local test_command="$3"
    ((TOTAL_TESTS++))
    echo -n "[$category] $test_name... "
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN:-}PASS${NC:-}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED:-}FAIL${NC:-}"
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
    echo -e "[$category] $test_name... ${CYAN:-}SKIP${NC:-} ($reason)"
}

# Pre-flight check
preflight_check() {
    echo -e "${BLUE:-}Pre-flight Check${NC:-}"
    echo "=================================="

    # Check if chezmoi has been applied
    if [ ! -d "$HOME/.zsh" ] && [ -d home/dot_zsh ]; then
        echo -e "${YELLOW:-}Warning: Dotfiles not applied yet!${NC:-}"
        echo -e "Run: ${GREEN:-}chezmoi apply${NC:-} to apply your dotfiles"
        echo ""
    fi

    # Platform info
    local platform_name="${OS}"
    if $IS_NIXOS; then
        platform_name="NixOS"
    elif $IS_MACOS; then
        platform_name="macOS"
    fi
    echo -e "Platform: ${CYAN:-}$platform_name${NC:-}"
    echo ""
}

# =============================================================================
# TEST SUITE
# =============================================================================
echo -e "${BLUE:-}Dotfiles Test Suite${NC:-}"
echo "=================================="

# Run pre-flight check
preflight_check

# =============================================================================
# CORE INFRASTRUCTURE TESTS
# =============================================================================
echo -e "\n${YELLOW:-}Core Infrastructure Tests${NC:-}"

run_test "Core" "chezmoi installation" "command -v chezmoi"
run_test "Core" "git repository" "test -d .git"
run_test "Core" "chezmoi configuration" "test -f chezmoi.toml"
run_test "Core" "Makefile exists" "test -f Makefile"

# =============================================================================
# SHELL CONFIGURATION TESTS
# =============================================================================
echo -e "\n${YELLOW:-}Shell Configuration Tests${NC:-}"

run_test "Shell" "zshrc existence" "test -f \"$HOME/.zshrc\""
run_test "Shell" "zshrc syntax" "zsh -n \"$HOME/.zshrc\""
run_test "Shell" "modular zsh directory" "test -d \"$HOME/.zsh\""
run_test "Shell" "modules.zsh existence" "test -f \"$HOME/.zsh/modules.zsh\""
run_test "Shell" "modules.zsh syntax" "zsh -n \"$HOME/.zsh/modules.zsh\""

# =============================================================================
# TOOL INSTALLATION TESTS
# =============================================================================
echo -e "\n${YELLOW:-}Tool Installation Tests${NC:-}"

# Check Oh My Zsh if enabled
if grep -q "ohmyzsh = true" chezmoi.toml 2>/dev/null; then
    run_test "Tools" "Oh My Zsh installation" "test -d \"$HOME/.oh-my-zsh\""
else
    skip_test "Tools" "Oh My Zsh installation" "not enabled in config"
fi

# Check package managers based on platform
if $IS_MACOS; then
    run_test "Tools" "Homebrew installation" "command -v brew"
elif $IS_NIXOS; then
    skip_test "Tools" "Homebrew installation" "NixOS uses Nix"
    run_test "Tools" "Nix installation" "command -v nix"
else
    # Generic Linux - could have either
    if command -v brew >/dev/null 2>&1; then
        run_test "Tools" "Homebrew installation" "command -v brew"
    else
        skip_test "Tools" "Homebrew installation" "not installed"
    fi
fi

# Check common development tools
run_test "Tools" "git installation" "command -v git"

# Vim/Neovim check
if command -v nvim >/dev/null 2>&1; then
    run_test "Tools" "neovim installation" "command -v nvim"
elif command -v vim >/dev/null 2>&1; then
    run_test "Tools" "vim installation" "command -v vim"
else
    run_test "Tools" "vim/neovim installation" "command -v vim || command -v nvim"
fi

# =============================================================================
# CONFIGURATION VALIDATION TESTS
# =============================================================================
echo -e "\n${YELLOW:-}Configuration Validation Tests${NC:-}"

run_test "Config" "chezmoi verify" "chezmoi verify"
run_test "Config" "no uncommitted changes" "git diff --quiet"
run_test "Config" "managed files exist" "chezmoi managed | head -5 | xargs -I {} test -e {}"

# =============================================================================
# INTEGRATION TESTS
# =============================================================================
echo -e "\n${YELLOW:-}Integration Tests${NC:-}"

run_test "Integration" "zsh configuration syntax" "zsh -n \"$HOME/.zshrc\""

# =============================================================================
# ENCRYPTION TESTS
# =============================================================================
echo -e "\n${YELLOW:-}Encryption Tests${NC:-}"

run_test "Encryption" "age CLI installed" "command -v age"
run_test "Encryption" "age key file exists" "test -f \"$HOME/.config/chezmoi/age_key.txt\""
run_test "Encryption" "age key file permissions" "test \"\$(stat -f '%Lp' \"$HOME/.config/chezmoi/age_key.txt\" 2>/dev/null || stat -c '%a' \"$HOME/.config/chezmoi/age_key.txt\" 2>/dev/null)\" = '600'"
run_test "Encryption" "encrypted source files exist" "ls home/dot_ssh/encrypted_* home/dot_zsh/core/encrypted_* >/dev/null 2>&1"

# =============================================================================
# SECURITY TESTS
# =============================================================================
echo -e "\n${YELLOW:-}Security Tests${NC:-}"

run_test "Security" "no sensitive files in repo" "! git ls-files | grep -E '\.(key|pem|p12|pfx)$'"
run_test "Security" "SSH config exists" "test -f \"$HOME/.ssh/config\""

# =============================================================================
# TEST SUMMARY
# =============================================================================
echo -e "\n${BLUE:-}Test Summary${NC:-}"
echo "=================================="
echo -e "${GREEN:-}Passed: $PASSED_TESTS${NC:-}"
echo -e "${RED:-}Failed: $FAILED_TESTS${NC:-}"
echo -e "${CYAN:-}Skipped: $SKIPPED_TESTS${NC:-}"
echo -e "${BLUE:-}Total: $TOTAL_TESTS${NC:-}"

# Calculate success rate (excluding skipped tests)
if [ $((TOTAL_TESTS - SKIPPED_TESTS)) -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / (TOTAL_TESTS - SKIPPED_TESTS)))
    echo -e "${BLUE:-}Success Rate: ${SUCCESS_RATE}% (excluding skipped)${NC:-}"
fi

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN:-}All tests passed! Your dotfiles are working correctly.${NC:-}"
    if [ $SKIPPED_TESTS -gt 0 ]; then
        echo -e "${CYAN:-}Note: $SKIPPED_TESTS tests were skipped (platform-specific or not configured)${NC:-}"
    fi
    exit 0
else
    echo -e "\n${RED:-}Some tests failed. Please check the output above.${NC:-}"
    if [ ! -d "$HOME/.zsh" ] && [ -d home/dot_zsh ]; then
        echo -e "\n${YELLOW:-}Tip: Run 'chezmoi apply' to apply your dotfiles first${NC:-}"
    fi
    exit 1
fi
