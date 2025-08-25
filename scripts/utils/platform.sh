#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_INIT_PATH="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1)"
source "$SCRIPT_DIR/${SCRIPT_INIT_PATH#./}"


# Platform detection utility for dotfiles with smart caching
# This script provides platform-specific variables and functions

# Load cached platform detection if available
if [[ -f "$SCRIPT_DIR/cache.sh" ]]; then
    source "$SCRIPT_DIR/cache.sh"
    # Use cached platform detection
    if cached_platform_info=$(cached_platform_detect 2>/dev/null); then
        eval "$cached_platform_info"
    else
        # Fallback to manual detection and cache it
        perform_platform_detection
    fi
else
    # Original detection method (fallback)
    perform_platform_detection
fi

# Platform detection function
perform_platform_detection() {
    # Detect operating system
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        ARCH="$(uname -m)"
        IS_LINUX=true
        IS_MACOS=false
        # Check for NixOS specifically
        if [ -f /etc/os-release ] && grep -q "NixOS" /etc/os-release; then
            IS_NIXOS=true
            DISTRO="nixos"
        else
            IS_NIXOS=false
            DISTRO="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        ARCH="$(uname -m)"
        IS_MACOS=true
        IS_LINUX=false
        IS_NIXOS=false
        DISTRO="macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
        ARCH="$(uname -m)"
        IS_MACOS=false
        IS_LINUX=false
        IS_NIXOS=false
        DISTRO="windows"
    else
        OS="unknown"
        ARCH="$(uname -m)"
        IS_MACOS=false
        IS_LINUX=false
        IS_NIXOS=false
        DISTRO="unknown"
    fi
}

# Set boolean flags for convenience
IS_MACOS=false
IS_LINUX=false
if [[ "$OS" == "macos" ]]; then
    IS_MACOS=true
elif [[ "$OS" == "linux" ]]; then
    IS_LINUX=true
fi

# Detect architecture
ARCH=$(uname -m)

# Detect package managers
if command -v brew &> /dev/null; then
    HAS_BREW=true
    if [[ "$ARCH" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew"
    else
        BREW_PREFIX="/usr/local"
    fi
else
    HAS_BREW=false
    BREW_PREFIX=""
fi

if command -v apt &> /dev/null; then
    HAS_APT=true
else
    HAS_APT=false
fi

if command -v pacman &> /dev/null; then
    HAS_PACMAN=true
else
    HAS_PACMAN=false
fi

# Check for Nix
if command -v nix &> /dev/null; then
    HAS_NIX=true
else
    HAS_NIX=false
fi

# Export variables
export OS
export ARCH
export DISTRO
export IS_MACOS
export IS_LINUX
export IS_NIXOS
export HAS_BREW
export HAS_APT
export HAS_PACMAN
export HAS_NIX
export BREW_PREFIX

# Platform-specific functions
is_macos() {
    [[ "$OS" == "macos" ]]
}

is_linux() {
    [[ "$OS" == "linux" ]]
}

is_windows() {
    [[ "$OS" == "windows" ]]
}

has_brew() {
    [[ "$HAS_BREW" == true ]]
}

has_apt() {
    [[ "$HAS_APT" == true ]]
}

has_pacman() {
    [[ "$HAS_PACMAN" == true ]]
}

# Print platform info
print_platform_info() {
    echo "Platform Information:"
    echo "  OS: $OS"
    echo "  Architecture: $ARCH"
    echo "  Homebrew: $HAS_BREW"
    echo "  APT: $HAS_APT"
    echo "  Pacman: $HAS_PACMAN"
    if [[ -n "$BREW_PREFIX" ]]; then
        echo "  Homebrew Prefix: $BREW_PREFIX"
    fi
}
