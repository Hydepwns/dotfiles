#!/usr/bin/env bash

# Platform.sh - Independent platform detection utilities
# NOTE: This file MUST NOT source script-init.sh to avoid circular dependency

# Platform detection function (must be defined before use)
perform_platform_detection() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        ARCH="$(uname -m)"
        IS_LINUX=true
        IS_MACOS=false
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

# Run detection: try cache first, fall back to direct detection
if [[ -f "$SCRIPT_DIR/cache.sh" ]]; then
    source "$SCRIPT_DIR/cache.sh"
    if cached_platform_info=$(cached_platform_detect 2>/dev/null); then
        eval "$cached_platform_info"
    else
        perform_platform_detection
    fi
else
    perform_platform_detection
fi

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
