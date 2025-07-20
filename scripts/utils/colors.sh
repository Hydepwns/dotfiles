#!/bin/bash

# Shared color utilities for dotfiles scripts
# This file provides consistent color output across all scripts

# Source constants if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/constants.sh" ]]; then
    source "$SCRIPT_DIR/constants.sh"
fi

# Color definitions (single source of truth)
get_color() {
    local color="$1"
    case "$color" in
        "RED") printf '\033[0;31m' ;;
        "GREEN") printf '\033[0;32m' ;;
        "YELLOW") printf '\033[1;33m' ;;
        "BLUE") printf '\033[0;34m' ;;
        "PURPLE") printf '\033[0;35m' ;;
        "CYAN") printf '\033[0;36m' ;;
        "NC") printf '\033[0m' ;;
        *) printf '\033[0m' ;;
    esac
}

# Export color variables for backward compatibility
export RED
RED="$(get_color RED)"
export GREEN
GREEN="$(get_color GREEN)"
export YELLOW
YELLOW="$(get_color YELLOW)"
export BLUE
BLUE="$(get_color BLUE)"
export PURPLE
PURPLE="$(get_color PURPLE)"
export CYAN
CYAN="$(get_color CYAN)"
export NC
NC="$(get_color NC)"

# Function to print colored output
print_status() {
    local status="$1"
    local message="$2"
    local color=""
    local icon=""

    case "$status" in
        "OK")
            color="$(get_color GREEN)"
            icon="✓"
            ;;
        "WARN")
            color="$(get_color YELLOW)"
            icon="⚠"
            ;;
        "ERROR")
            color="$(get_color RED)"
            icon="✗"
            ;;
        "INFO")
            color="$(get_color BLUE)"
            icon="ℹ"
            ;;
        "DEBUG")
            color="$(get_color PURPLE)"
            icon="🔍"
            ;;
        *)
            color="$(get_color NC)"
            icon="•"
            ;;
    esac

    echo -e "${color}${icon}$(get_color NC) $message"
}

# Print section header
print_section() {
    local title="$1"
    echo
    echo -e "$(get_color CYAN)=== $title ===$(get_color NC)"
    echo
}

# Print subsection header
print_subsection() {
    local title="$1"
    echo -e "$(get_color BLUE)--- $title ---$(get_color NC)"
}
