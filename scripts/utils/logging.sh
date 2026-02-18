#!/usr/bin/env bash

# Logging.sh - Centralized logging utilities
# Source this for consistent logging across all scripts
#
# Supports:
# - QUIET=true to suppress info/success messages
# - DEBUG=true to enable debug messages
# - Both naming conventions: log_info/info, log_success/success, etc.

# Ensure colors are available
if [[ -z "$NC" ]]; then
    if [[ -t 1 ]]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        PURPLE='\033[0;35m'
        CYAN='\033[0;36m'
        NC='\033[0m'
    else
        RED='' GREEN='' YELLOW='' BLUE='' PURPLE='' CYAN='' NC=''
    fi
fi

# Core logging functions with QUIET/DEBUG support
log_info() {
    if [[ "${QUIET:-false}" != "true" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_success() {
    if [[ "${QUIET:-false}" != "true" ]]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Short aliases (used by setup scripts)
info() {
    if [[ "${QUIET:-false}" != "true" ]]; then
        echo -e "${CYAN}[*]${NC} $1"
    fi
}

success() {
    if [[ "${QUIET:-false}" != "true" ]]; then
        echo -e "${GREEN}[+]${NC} $1"
    fi
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[-]${NC} $1" >&2
}

# Export all functions
export -f log_info log_success log_warning log_error log_debug
export -f info success warn error

# Success marker
export LOGGING_LOADED=true
