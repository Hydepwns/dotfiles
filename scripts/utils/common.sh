#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_INIT_PATH="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1)"
source "$SCRIPT_DIR/${SCRIPT_INIT_PATH#./}"


# Common utilities loader for dotfiles scripts
# This file sources all commonly needed utilities in the correct order

# Get the directory of this script

# Source utilities in order of dependency
# 1. Constants (defines variables used by other scripts)

# 2. Colors (provides color definitions and functions)  

# 3. Platform detection (OS, architecture, package managers)

# 4. Helper functions (logging, validation, etc.)

# 5. Consolidated patterns library (eliminates code duplication)

# 6. Advanced patterns library (Level 2 consolidation)

# Additional consolidated functions
# =================================

# Configuration reading helpers
read_chezmoi_config() {
    local key="$1"
    local config_file="${2:-chezmoi.toml}"
    
    if [ -f "$config_file" ]; then
        grep -E "^${key}\s*=" "$config_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "'"'"
    fi
}

# Check if feature is enabled in chezmoi.toml
is_feature_enabled() {
    local feature="$1"
    local config_file="${2:-chezmoi.toml}"
    
    local value
    value=$(read_chezmoi_config "$feature" "$config_file")
    [[ "$value" == "true" ]]
}

# Unified installation check
can_install_package() {
    local package="$1"
    
    if $IS_MACOS && command -v brew >/dev/null 2>&1; then
        return 0
    elif $IS_LINUX && command -v apt >/dev/null 2>&1; then
        return 0
    elif $IS_NIXOS && command -v nix-env >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Unified package installation
install_package() {
    local package="$1"
    local nix_package="${2:-$package}"
    
    if $IS_MACOS && command -v brew >/dev/null 2>&1; then
        print_status "INFO" "Installing $package via Homebrew..."
        brew install "$package"
    elif $IS_LINUX && command -v apt >/dev/null 2>&1; then
        print_status "INFO" "Installing $package via apt..."
        sudo apt update && sudo apt install -y "$package"
    elif $IS_NIXOS && command -v nix-env >/dev/null 2>&1; then
        print_status "INFO" "Installing $nix_package via Nix..."
        nix-env -iA "nixos.$nix_package"
    else
        print_status "ERROR" "No supported package manager found for $package"
        return 1
    fi
}

# Export that common utilities have been loaded
