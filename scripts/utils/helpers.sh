#!/usr/bin/env bash

# Helper utilities for dotfiles management
# This script provides common functions used across dotfiles

# Source constants if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/constants.sh" ]]; then
    source "$SCRIPT_DIR/constants.sh"
fi

# Logging functions
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
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Handle errors with proper exit codes
handle_error() {
    local exit_code=$?
    local line_number=$1
    local script_name=${BASH_SOURCE[1]}
    log_error "Error occurred in $script_name at line $line_number (exit code: $exit_code)"
    exit $exit_code
}

# Validate required arguments
validate_required_args() {
    local args=("$@")
    for arg in "${args[@]}"; do
        if [[ -z "$arg" ]]; then
            log_error "Required argument is missing or empty"
            return $EXIT_INVALID_ARGS
        fi
    done
    return $EXIT_SUCCESS
}

# Validate path
validate_path() {
    local path="$1"
    local type="${2:-file}"

    case "$type" in
        "file")
            [[ -f "$path" && -r "$path" ]]
            ;;
        "dir")
            [[ -d "$path" && -r "$path" ]]
            ;;
        "executable")
            [[ -f "$path" && -x "$path" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Check if file exists and is readable
file_exists() {
    [[ -f "$1" ]] && [[ -r "$1" ]]
}

# Check if directory exists
dir_exists() {
    [[ -d "$1" ]]
}

# Create directory if it doesn't exist
ensure_dir() {
    if ! dir_exists "$1"; then
        log_info "Creating directory: $1"
        mkdir -p "$1"
    fi
}

# Backup file if it exists
backup_file() {
    local file="$1"
    if file_exists "$file"; then
        local backup
        backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up $file to $backup"
        cp "$file" "$backup"
        return 0
    fi
    return 1
}

# Safe symlink creation
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ -L "$target" ]]; then
        log_warning "Symlink already exists at $target"
        return 1
    elif file_exists "$target"; then
        log_warning "File already exists at $target, backing up"
        backup_file "$target"
        rm "$target"
    fi

    log_info "Creating symlink: $source -> $target"
    ln -s "$source" "$target"
    return $?
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Require root access
require_root() {
    if ! is_root; then
        log_error "This operation requires root privileges"
        exit 1
    fi
}

# Ask for confirmation
confirm() {
    local message="$1"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        read -p "$message [Y/n]: " -n 1 -r
    else
        read -p "$message [y/N]: " -n 1 -r
    fi
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
        return 1
    elif [[ -z $REPLY ]]; then
        [[ "$default" == "y" ]]
    else
        return 1
    fi
}

# Get the directory where this script is located
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

# Get the root directory of the dotfiles repository
get_dotfiles_root() {
    local script_dir
    script_dir=$(get_script_dir)
    dirname "$(dirname "$(dirname "$script_dir")")"
}

# Check if we're in a git repository
is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

# Get git status
get_git_status() {
    if is_git_repo; then
        git status --porcelain
    else
        return 1
    fi
}

# Check if there are uncommitted changes
has_uncommitted_changes() {
    [[ -n "$(get_git_status)" ]]
}

# Print subsection header
print_subsection() {
    local title="$1"
    echo -e "${BLUE}--- $title ---${NC}"
}

# Wait for user input
pause() {
    read -rp "Press Enter to continue..."
}

# Check if running in interactive mode
is_interactive() {
    [[ -t 0 ]]
}

# Show progress bar
show_progress() {
    local current="$1"
    local total="$2"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\r["
    printf "%${filled}s" | tr ' ' '#'
    printf "%${empty}s" | tr ' ' '-'
    printf "] %d%%" "$percentage"

    if [[ "$current" -eq "$total" ]]; then
        echo
    fi
}
