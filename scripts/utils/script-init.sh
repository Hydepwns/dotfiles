#!/usr/bin/env bash

# Universal Script Initialization Library
# Eliminates duplicate initialization patterns across all scripts

# Initialize a script with standard utilities and error handling
# Usage: source "$UTILS_DIR/script-init.sh"

# Prevent multiple initialization
[[ -n "$SCRIPT_INITIALIZED" ]] && return 0

# Calculate paths relative to any script location
if [[ -z "$SCRIPT_DIR" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
fi

# Find dotfiles root (traverse up until we find dotfiles or chezmoi.toml)
find_dotfiles_root() {
    local dir="$SCRIPT_DIR"
    
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/chezmoi.toml" ]] || [[ -f "$dir/dotfiles" ]] || [[ "$(basename "$dir")" == "dotfiles" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    
    # Fallback to script directory
    echo "$SCRIPT_DIR"
}

# Set standard path variables
export DOTFILES_ROOT="${DOTFILES_ROOT:-$(find_dotfiles_root)}"
export UTILS_DIR="${UTILS_DIR:-$DOTFILES_ROOT/scripts/utils}"
export CACHE_DIR="${CACHE_DIR:-$DOTFILES_ROOT/.cache}"
export LOG_DIR="${LOG_DIR:-$CACHE_DIR/logs}"

# Ensure required directories exist
ensure_directories() {
    local dirs=(
        "$CACHE_DIR"
        "$LOG_DIR"
        "$CACHE_DIR/metrics"
        "$CACHE_DIR/tests"
    )
    
    for dir in "${dirs[@]}"; do
        [[ ! -d "$dir" ]] && mkdir -p "$dir"
    done
}

# Source utilities in correct order
source_utilities() {
    local utils=(
        "constants.sh"
        "colors.sh" 
        "platform.sh"
        "helpers.sh"
        "error-handling.sh"
    )
    
    for util in "${utils[@]}"; do
        local util_path="$UTILS_DIR/$util"
        if [[ -f "$util_path" ]]; then
            source "$util_path" || {
                echo "ERROR: Failed to source $util" >&2
                exit 1
            }
        fi
    done
}

# Initialize logging for the script
init_logging() {
    local script_name
    script_name="$(basename "${BASH_SOURCE[1]}" .sh)"
    
    export SCRIPT_LOG_FILE="$LOG_DIR/${script_name}.log"
    export SCRIPT_NAME="$script_name"
    
    # Create log file if it doesn't exist
    [[ ! -f "$SCRIPT_LOG_FILE" ]] && touch "$SCRIPT_LOG_FILE"
}

# Set up error handling
init_error_handling() {
    # Source error handling first
    if [[ -f "$UTILS_DIR/error-handling.sh" ]]; then
        source "$UTILS_DIR/error-handling.sh"
        setup_error_handling
    else
        # Fallback error handling
        set -euo pipefail
        trap 'echo "ERROR: Script failed at line $LINENO" >&2' ERR
    fi
}

# Main initialization function
init_script() {
    ensure_directories
    init_error_handling
    init_logging
    source_utilities
    
    # Mark as initialized
    export SCRIPT_INITIALIZED=true
    export SCRIPT_INIT_TIME="$(date '+%s')"
    
    # Log script start
    if [[ -n "${SCRIPT_LOG_FILE:-}" ]] && command -v log_message >/dev/null 2>&1; then
        log_message "INFO" "Script $SCRIPT_NAME initialized"
    fi
}

# Run initialization
init_script

# Provide common utility functions
# ================================

# Unified command check with caching
declare -A COMMAND_CACHE
has_command() {
    local cmd="$1"
    
    if [[ -n "${COMMAND_CACHE[$cmd]:-}" ]]; then
        [[ "${COMMAND_CACHE[$cmd]}" == "true" ]]
        return $?
    fi
    
    if command -v "$cmd" >/dev/null 2>&1; then
        COMMAND_CACHE[$cmd]="true"
        return 0
    else
        COMMAND_CACHE[$cmd]="false"
        return 1
    fi
}

# Unified date formatting
get_timestamp() {
    local format="${1:-iso}"
    
    case "$format" in
        "iso")
            date -u "+%Y-%m-%dT%H:%M:%SZ"
            ;;
        "log")
            date "+%Y-%m-%d %H:%M:%S"
            ;;
        "file")
            date "+%Y%m%d-%H%M%S"
            ;;
        "human")
            date "+%B %d, %Y at %I:%M %p"
            ;;
        *)
            date "+$format"
            ;;
    esac
}

# Smart directory creation with logging
ensure_dir() {
    local dir="$1"
    local mode="${2:-755}"
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chmod "$mode" "$dir"
        
        if command -v log_message >/dev/null 2>&1; then
            log_message "DEBUG" "Created directory: $dir"
        fi
    fi
}

# Unified temporary file/directory creation
create_temp() {
    local type="${1:-file}"  # file or dir
    local template="${2:-tmp.XXXXXX}"
    local base_dir="${3:-$CACHE_DIR}"
    
    ensure_dir "$base_dir"
    
    case "$type" in
        "file")
            mktemp "$base_dir/$template"
            ;;
        "dir")
            mktemp -d "$base_dir/$template"
            ;;
        *)
            echo "ERROR: Invalid temp type: $type" >&2
            return 1
            ;;
    esac
}

# Safe file operations with backup
safe_write() {
    local file="$1"
    local content="$2"
    local backup="${3:-true}"
    
    ensure_dir "$(dirname "$file")"
    
    # Create backup if requested and file exists
    if [[ "$backup" == "true" ]] && [[ -f "$file" ]]; then
        local backup_file="${file}.backup.$(get_timestamp file)"
        cp "$file" "$backup_file"
        
        if command -v log_message >/dev/null 2>&1; then
            log_message "DEBUG" "Created backup: $backup_file"
        fi
    fi
    
    # Write content
    echo "$content" > "$file"
}

# Unified progress indication
show_progress() {
    local message="$1"
    local step="${2:-}"
    local total="${3:-}"
    
    if [[ -n "$step" ]] && [[ -n "$total" ]]; then
        echo -ne "\r${message} (${step}/${total})..."
    else
        echo -ne "\r${message}..."
    fi
}

# Script performance timing
start_timer() {
    local timer_name="${1:-default}"
    declare -g "TIMER_${timer_name}=$(date +%s%N)"
}

end_timer() {
    local timer_name="${1:-default}"
    local timer_var="TIMER_${timer_name}"
    local start_time="${!timer_var:-0}"
    local end_time="$(date +%s%N)"
    local duration_ns=$((end_time - start_time))
    local duration_ms=$((duration_ns / 1000000))
    
    echo "$duration_ms"
}

# Export all functions for subshells
export -f has_command get_timestamp ensure_dir create_temp safe_write show_progress start_timer end_timer

# Mark initialization complete
if command -v log_message >/dev/null 2>&1; then
    log_message "DEBUG" "Script initialization library loaded successfully"
fi