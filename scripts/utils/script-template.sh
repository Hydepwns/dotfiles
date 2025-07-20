#!/bin/bash
# Standard script template for DROO's dotfiles
# Copy this template when creating new scripts

set -euo pipefail  # Strict error handling

# Script metadata
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_VERSION="1.0.0"
SCRIPT_DESCRIPTION="Description of what this script does"

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/colors.sh"

# Function to show usage
show_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] <ARGS>

$SCRIPT_DESCRIPTION

Options:
    -h, --help      Show this help message
    -v, --version   Show version information
    -d, --debug     Enable debug mode
    -q, --quiet     Suppress output (except errors)

Examples:
    $SCRIPT_NAME arg1 arg2
    $SCRIPT_NAME --debug arg1

EOF
}

# Function to parse arguments
parse_args() {
    local args=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit $EXIT_SUCCESS
                ;;
            -v|--version)
                echo "$SCRIPT_NAME version $SCRIPT_VERSION"
                exit $EXIT_SUCCESS
                ;;
            -d|--debug)
                export DEBUG=true
                shift
                ;;
            -q|--quiet)
                export QUIET=true
                shift
                ;;
            --)
                shift
                args+=("$@")
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit $EXIT_INVALID_ARGS
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    # Return positional arguments
    echo "${args[@]}"
}

# Function to validate dependencies
validate_dependencies() {
    local missing_deps=()

    # Add your required dependencies here
    local required_commands=("chezmoi" "git")

    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit $EXIT_MISSING_DEPENDENCY
    fi
}

# Function to cleanup on exit
cleanup() {
    local exit_code=$?

    # Add cleanup logic here
    log_debug "Cleaning up..."

    exit $exit_code
}

# Set up trap for cleanup
trap cleanup EXIT

# Main function
main() {
    log_info "Starting $SCRIPT_NAME"

    # Validate dependencies
    validate_dependencies

    # Parse arguments
    local args
    mapfile -t args < <(parse_args "$@")

    # Validate required arguments
    if [[ ${#args[@]} -lt 1 ]]; then
        log_error "Missing required arguments"
        show_usage
        exit $EXIT_INVALID_ARGS
    fi

    # Your script logic here
    log_info "Processing arguments: ${args[*]}"

    # Example: process each argument
    for arg in "${args[@]}"; do
        log_debug "Processing: $arg"
        # Add your processing logic here
    done

    log_success "$SCRIPT_NAME completed successfully"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
