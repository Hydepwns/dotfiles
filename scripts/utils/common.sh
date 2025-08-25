#!/usr/bin/env bash

# Use simple script initialization (no segfaults!)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/simple-init.sh"


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

# Basic platform detection (for compatibility)
case "$(uname -s)" in
    Darwin*) IS_MACOS=true; IS_LINUX=false; IS_NIXOS=false ;;
    Linux*)
        if [[ -f /etc/NIXOS ]]; then
            IS_NIXOS=true; IS_LINUX=false; IS_MACOS=false
        else
            IS_LINUX=true; IS_NIXOS=false; IS_MACOS=false
        fi
        ;;
    *) IS_MACOS=false; IS_LINUX=false; IS_NIXOS=false ;;
esac

# Simple utilities (no dependencies)
log_info() { echo -e "${BLUE:-}[INFO]${NC:-} $1"; }
log_success() { echo -e "${GREEN:-}[SUCCESS]${NC:-} $1"; }
log_error() { echo -e "${RED:-}[ERROR]${NC:-} $1" >&2; }
log_warning() { echo -e "${YELLOW:-}[WARNING]${NC:-} $1"; }

# Exit codes
EXIT_SUCCESS=0
EXIT_INVALID_ARGS=1
EXIT_FAILURE=1

# Simple utility functions  
file_exists() { test -f "$1"; }
dir_exists() { test -d "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Status printing functions for compatibility
print_status() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        "OK") log_success "$message" ;;
        "INFO") log_info "$message" ;;
        "ERROR") log_error "$message" ;;
        "WARN") log_warning "$message" ;;
        *) log_info "$message" ;;
    esac
}

print_section() {
    log_info "=== $1 ==="
}

# Export functions that might be used by other scripts
export -f log_info log_success log_error log_warning
export -f file_exists dir_exists command_exists
export -f print_status print_section

# Export that common utilities have been loaded
