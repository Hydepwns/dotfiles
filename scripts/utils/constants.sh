#!/usr/bin/env bash
# Constants and exit codes for DROO's dotfiles
# This file provides consistent exit codes and error messages across all scripts

# Exit codes
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_INVALID_ARGS=2
EXIT_MISSING_DEPENDENCY=3
EXIT_PERMISSION_DENIED=4
EXIT_FILE_NOT_FOUND=5
EXIT_NETWORK_ERROR=6
EXIT_TIMEOUT=7

# Common error messages (using functions for compatibility)
get_error_message() {
    local exit_code="$1"
    case "$exit_code" in
        "$EXIT_SUCCESS") echo "Operation completed successfully" ;;
        "$EXIT_FAILURE") echo "Operation failed" ;;
        "$EXIT_INVALID_ARGS") echo "Invalid arguments provided" ;;
        "$EXIT_MISSING_DEPENDENCY") echo "Required dependency not found" ;;
        "$EXIT_PERMISSION_DENIED") echo "Permission denied" ;;
        "$EXIT_FILE_NOT_FOUND") echo "File or directory not found" ;;
        "$EXIT_NETWORK_ERROR") echo "Network error occurred" ;;
        "$EXIT_TIMEOUT") echo "Operation timed out" ;;
        *) echo "Unknown error" ;;
    esac
}

# Script metadata
SCRIPT_VERSION="1.0.0"
SCRIPT_AUTHOR="DROO"

# Identity (reads from chezmoi data when available)
if command -v chezmoi &>/dev/null && command -v jq &>/dev/null; then
    _chezmoi_data="$(chezmoi data --format json 2>/dev/null || echo '{}')"
    GITHUB_USER="${GITHUB_USER:-$(echo "$_chezmoi_data" | jq -r '.github // empty' 2>/dev/null)}"
    USER_NAME="${USER_NAME:-$(echo "$_chezmoi_data" | jq -r '.name // empty' 2>/dev/null)}"
    USER_EMAIL="${USER_EMAIL:-$(echo "$_chezmoi_data" | jq -r '.email // empty' 2>/dev/null)}"
    AGE_RECIPIENT="${AGE_RECIPIENT:-$(echo "$_chezmoi_data" | jq -r '.age_recipient // empty' 2>/dev/null)}"
    unset _chezmoi_data
fi
GITHUB_USER="${GITHUB_USER:-}"
USER_NAME="${USER_NAME:-}"
USER_EMAIL="${USER_EMAIL:-}"
AGE_RECIPIENT="${AGE_RECIPIENT:-}"
SCRIPT_REPO="${SCRIPT_REPO:-https://github.com/${GITHUB_USER:-hydepwns}/dotfiles}"

# Infrastructure (customize per-user via env vars)
OP_VAULT="${OP_VAULT:-Private}"
OP_AGE_ITEM="${OP_AGE_ITEM:-Dotfiles Age Key}"
TAILSCALE_USER="${TAILSCALE_USER:-$USER}"

# Common paths
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../backups" && pwd)"
CONFIG_DIR="$HOME/.config"
CACHE_DIR="$HOME/.cache"

# Tool configurations (using functions for compatibility)
get_tool_command() {
    local tool="$1"
    case "$tool" in
        "rust") echo "cargo" ;;
        "nodejs") echo "node" ;;
        "python") echo "python3" ;;
        "elixir") echo "elixir" ;;
        "go") echo "go" ;;
        "lua") echo "lua" ;;
        "docker") echo "docker" ;;
        "git") echo "git" ;;
        "chezmoi") echo "chezmoi" ;;
        "brew") echo "brew" ;;
        *) echo "" ;;
    esac
}

# Platform detection
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

# Export constants for use in other scripts
export EXIT_SUCCESS EXIT_FAILURE EXIT_INVALID_ARGS EXIT_MISSING_DEPENDENCY
export EXIT_PERMISSION_DENIED EXIT_FILE_NOT_FOUND EXIT_NETWORK_ERROR EXIT_TIMEOUT
export PLATFORM ARCH
export SCRIPT_VERSION SCRIPT_AUTHOR SCRIPT_REPO
export GITHUB_USER USER_NAME USER_EMAIL AGE_RECIPIENT
export OP_VAULT OP_AGE_ITEM TAILSCALE_USER
export DOTFILES_ROOT SCRIPTS_DIR BACKUP_DIR CONFIG_DIR CACHE_DIR
export get_tool_command
