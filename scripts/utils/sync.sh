#!/bin/bash
# Sync utility for DROO's dotfiles

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/colors.sh"

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 <sync-type>

Sync types:
    local       - Sync local changes to repository
    remote      - Sync from remote repository

Examples:
    $0 local
    $0 remote

EOF
}

# Function to sync local changes
sync_local() {
    log_info "Syncing local changes to repository..."

    # Check if we're in a git repository
    if ! is_git_repo; then
        log_error "Not in a git repository"
        return "$EXIT_FAILURE"
    fi

    # Show differences
    log_info "Showing differences..."
    chezmoi diff

    # Ask for confirmation
    if ! confirm "Apply changes?" "n"; then
        log_info "Sync cancelled"
        return "$EXIT_SUCCESS"
    fi

    # Add changes
    log_info "Adding changes..."
    if ! chezmoi add .; then
        log_error "Failed to add changes"
        return "$EXIT_FAILURE"
    fi

    # Commit changes
    local commit_message
    commit_message="Sync: $(date)"
    log_info "Committing changes: $commit_message"
    if ! chezmoi commit -m "$commit_message"; then
        log_error "Failed to commit changes"
        return "$EXIT_FAILURE"
    fi

    # Push to remote
    log_info "Pushing to remote..."
    if ! git push origin main; then
        log_error "Failed to push to remote"
        return "$EXIT_FAILURE"
    fi

    log_success "Changes synced successfully"
    return "$EXIT_SUCCESS"
}

# Function to sync from remote
sync_remote() {
    log_info "Syncing from remote repository..."

    # Check if we're in a git repository
    if ! is_git_repo; then
        log_error "Not in a git repository"
        return "$EXIT_FAILURE"
    fi

    # Update from remote
    log_info "Updating from remote..."
    if ! chezmoi update; then
        log_error "Failed to update from remote"
        return "$EXIT_FAILURE"
    fi

    # Apply changes
    log_info "Applying changes..."
    if ! chezmoi apply; then
        log_error "Failed to apply changes"
        return "$EXIT_FAILURE"
    fi

    log_success "Remote changes applied successfully"
    return "$EXIT_SUCCESS"
}

# Function to check sync status
check_sync_status() {
    log_info "Checking sync status..."

    # Check if we're in a git repository
    if ! is_git_repo; then
        log_error "Not in a git repository"
        return "$EXIT_FAILURE"
    fi

    # Check chezmoi status
    log_info "Chezmoi status:"
    chezmoi status

    # Check git status
    log_info "Git status:"
    git status --porcelain

    # Check for uncommitted changes
    if has_uncommitted_changes; then
        log_warning "There are uncommitted changes"
        return "$EXIT_FAILURE"
    else
        log_success "No uncommitted changes"
        return "$EXIT_SUCCESS"
    fi
}

# Function to resolve conflicts
resolve_conflicts() {
    log_info "Checking for conflicts..."

    # Check chezmoi conflicts
    local conflicts
    conflicts=$(chezmoi diff 2>/dev/null | grep -c "conflict" || echo "0")

    if [[ $conflicts -gt 0 ]]; then
        log_warning "Found $conflicts conflicts"

        if confirm "Resolve conflicts automatically?" "n"; then
            log_info "Resolving conflicts..."
            chezmoi merge
        else
            log_info "Please resolve conflicts manually"
            return "$EXIT_FAILURE"
        fi
    else
        log_success "No conflicts found"
    fi

    return "$EXIT_SUCCESS"
}

# Main function
main() {
    case "${1:-}" in
        "local")
            sync_local
            ;;
        "remote")
            sync_remote
            ;;
        "status")
            check_sync_status
            ;;
        "resolve")
            resolve_conflicts
            ;;
        *)
            show_usage
            exit "$EXIT_INVALID_ARGS"
            ;;
    esac
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
