#!/usr/bin/env bash
# Setup verification script for dotfiles
# This script checks if the dotfiles are properly set up and provides guidance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=simple-init.sh
source "$SCRIPT_DIR/simple-init.sh"

# Simple utility functions
command_exists() { command -v "$1" >/dev/null 2>&1; }
file_exists() { test -f "$1"; }
dir_exists() { test -d "$1"; }

# Simple config reading
is_config_enabled() {
    local key="$1"
    local config_file="$2"
    if file_exists "$config_file"; then
        grep -q "$key.*true" "$config_file" 2>/dev/null
    else
        return 1
    fi
}
# Simple platform detection (no dependencies)
OS="$(uname -s)"
IS_MACOS=false
IS_LINUX=false
IS_NIXOS=false
case "$OS" in
    Darwin)
        IS_MACOS=true
        PLATFORM="macOS"
        ;;
    Linux)
        IS_LINUX=true
        PLATFORM="Linux"
        [ -f /etc/os-release ] && grep -q "NixOS" /etc/os-release && IS_NIXOS=true && PLATFORM="NixOS"
        ;;
    *)
        PLATFORM="Unknown"
        ;;
esac

# Status tracking
ISSUES_FOUND=0
WARNINGS=0

# Set PLATFORM display name
if $IS_NIXOS; then
    PLATFORM="NixOS"
elif $IS_MACOS; then
    PLATFORM="macOS"
elif $IS_LINUX; then
    PLATFORM="Linux"
else
    PLATFORM="${OS:-Unknown}"
fi

echo -e "${BLUE:-}--- Dotfiles Setup Verification ---${NC:-}"
echo "=================================="
echo -e "Platform: ${BLUE:-}$PLATFORM${NC:-}"
echo ""

# Function to check a condition and report
check() {
    local description="$1"
    local command="$2"
    local fix_hint="$3"

    echo -n "Checking $description... "
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN:-}OK${NC:-}"
        return 0
    else
        echo -e "${RED:-}FAIL${NC:-}"
        if [ -n "$fix_hint" ]; then
            echo -e "  ${YELLOW:-}Fix: $fix_hint${NC:-}"
        fi
        ((ISSUES_FOUND++))
        return 1
    fi
}

# Function for warnings (non-critical issues)
warn_check() {
    local description="$1"
    local command="$2"
    local note="$3"

    echo -n "Checking $description... "
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN:-}OK${NC:-}"
        return 0
    else
        echo -e "${YELLOW:-}${NC:-}"
        if [ -n "$note" ]; then
            echo -e "  ${CYAN:-}Note: $note${NC:-}"
        fi
        ((WARNINGS++))
        return 1
    fi
}

echo -e "${YELLOW:-} Core Requirements${NC:-}"
echo "-------------------"
check "chezmoi installed" \
    "command -v chezmoi" \
    "Install chezmoi: https://www.chezmoi.io/install/"

check "git installed" \
    "command -v git" \
    "Install git via your package manager"

check "zsh installed" \
    "command -v zsh" \
    "Install zsh via your package manager"

echo ""
echo -e "${YELLOW:-} Repository Status${NC:-}"
echo "-------------------"
check "in dotfiles directory" \
    "test -f chezmoi.toml" \
    "cd to your dotfiles directory"

check "git repository initialized" \
    "test -d .git" \
    "Run: git init"

echo ""
echo -e "${YELLOW:-} Chezmoi Configuration${NC:-}"
echo "------------------------"
check "chezmoi.toml exists" \
    "test -f chezmoi.toml" \
    "Create chezmoi.toml with your configuration"

check "chezmoi source directory" \
    "test -d home" \
    "Ensure home/ directory exists with dotfiles"

# Check if dotfiles have been applied
DOTFILES_APPLIED=true
if [ ! -d ~/.zsh ] && [ -d home/dot_zsh ]; then
    DOTFILES_APPLIED=false
fi

if $DOTFILES_APPLIED; then
    check "dotfiles applied" "test -d ~/.zsh" ""
else
    check "dotfiles applied" "false" "Run: chezmoi apply"
fi

echo ""
echo -e "${YELLOW:-} Home Directory Files${NC:-}"
echo "----------------------"

if $DOTFILES_APPLIED; then
    check ".zshrc exists" "test -f ~/.zshrc" "Run: chezmoi apply"
    check ".zsh directory exists" "test -d ~/.zsh" "Run: chezmoi apply"

    # Check for valid .zshrc content
    if [ -f ~/.zshrc ]; then
        if [ "$(wc -l < ~/.zshrc)" -lt 5 ]; then
            echo -e "  ${YELLOW:-} .zshrc seems incomplete (less than 5 lines)${NC:-}"
            echo -e "  ${CYAN:-}Run: chezmoi apply to update${NC:-}"
            ((WARNINGS++))
        fi
    fi
fi

echo ""
echo -e "${YELLOW:-} Platform-Specific Tools${NC:-}"
echo "-------------------------"

if $IS_MACOS; then
    warn_check "Homebrew installed" \
        "command -v brew" \
        "Optional but recommended for macOS"
elif $IS_NIXOS; then
    check "Nix installed" \
        "command -v nix" \
        "Should be available on NixOS"

    warn_check "make command available" \
        "command -v make" \
        "Install with: nix-env -iA nixpkgs.gnumake"
fi

# Check for Oh My Zsh if configured
if is_config_enabled "ohmyzsh" "chezmoi.toml"; then
    echo ""
    echo -e "${YELLOW:-} Optional Components${NC:-}"
    echo "---------------------"
    warn_check "Oh My Zsh installed" \
        "test -d ~/.oh-my-zsh" \
        "Run bootstrap or install Oh My Zsh manually"
fi

# Check for Home Manager conflicts (NixOS)
if $IS_NIXOS; then
    echo ""
    echo -e "${YELLOW:-} NixOS Specific Checks${NC:-}"
    echo "-----------------------"

    if [ -L ~/.profile ]; then
        # Check if it's a Home Manager symlink
        if readlink ~/.profile | grep -q "home-manager-files"; then
            # Check if the target exists
            if [ ! -e ~/.profile ]; then
                echo -e "Checking .profile symlink... ${RED:-}[FAIL]${NC:-}"
                echo -e "  ${YELLOW:-}Broken Home Manager symlink detected${NC:-}"
                echo -e "  ${YELLOW:-}Fix: rm ~/.profile && chezmoi apply${NC:-}"
                ((ISSUES_FOUND++))
            else
                echo -e "Checking .profile symlink... ${GREEN:-}[OK]${NC:-}"
            fi
        fi
    fi
fi

echo ""
echo "=================================="
echo -e "${BLUE:-} Verification Summary${NC:-}"
echo "=================================="

if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN:-} All checks passed!${NC:-}"
    echo "Your dotfiles setup is complete and working correctly."
elif [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN:-} Core setup complete${NC:-}"
    echo -e "${YELLOW:-} $WARNINGS warning(s) found${NC:-}"
    echo "Your dotfiles are functional but some optional components may be missing."
else
    echo -e "${RED:-} $ISSUES_FOUND issue(s) found${NC:-}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW:-} $WARNINGS warning(s) found${NC:-}"
    fi
    echo ""
    echo "Please address the issues above to complete your setup."

    if ! $DOTFILES_APPLIED; then
        echo ""
        echo -e "${BLUE:-}Quick fix for most issues:${NC:-}"
        echo -e "  1. ${GREEN:-}chezmoi apply${NC:-} - Apply your dotfiles"
        echo -e "  2. ${GREEN:-}bash scripts/utils/verify-setup.sh${NC:-} - Run this script again"
    fi
fi

# Exit with appropriate code
if [ $ISSUES_FOUND -gt 0 ]; then
    exit $EXIT_FAILURE
else
    exit $EXIT_SUCCESS
fi
