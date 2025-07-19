#!/bin/bash

# Platform detection utility for dotfiles
# This script provides platform-specific variables and functions

# Detect operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
else
    OS="unknown"
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

# Export variables
export OS
export ARCH
export HAS_BREW
export HAS_APT
export HAS_PACMAN
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