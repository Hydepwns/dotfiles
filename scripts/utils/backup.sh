#!/usr/bin/env bash
# Backup utility for DROO's dotfiles

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/colors.sh"

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 <backup-type>

Backup types:
    data        - Create data backup (chezmoi data)
    full        - Create full backup with archive

Examples:
    $0 data
    $0 full

EOF
}

# Function to create data backup
create_data_backup() {
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file
    backup_file="$BACKUP_DIR/chezmoi-data-$timestamp.json"

    ensure_dir "$BACKUP_DIR"

    log_info "Creating data backup..."
    if chezmoi data > "$backup_file"; then
        log_success "Data backup created: $backup_file"
        return $EXIT_SUCCESS
    else
        log_error "Failed to create data backup"
        return $EXIT_FAILURE
    fi
}

# Function to create full backup
create_full_backup() {
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local archive_file
    archive_file="$BACKUP_DIR/dotfiles-$timestamp.tar.gz"
    local data_file
    data_file="$BACKUP_DIR/chezmoi-data-$timestamp.json"

    ensure_dir "$BACKUP_DIR"

    log_info "Creating full backup..."

    # Create archive
    if chezmoi archive --output "$archive_file"; then
        log_success "Archive created: $archive_file"
    else
        log_error "Failed to create archive"
        return $EXIT_FAILURE
    fi

    # Create data backup
    if chezmoi data > "$data_file"; then
        log_success "Data backup created: $data_file"
    else
        log_warning "Failed to create data backup"
    fi

    log_success "Full backup completed successfully"
    return $EXIT_SUCCESS
}

# Function to clean old backups
clean_old_backups() {
    local days
    days="${1:-30}"

    log_info "Cleaning backups older than $days days..."

    local cleaned_count
    cleaned_count=0

    # Clean archives
    while IFS= read -r -d '' file; do
        rm "$file"
        ((cleaned_count++))
    done < <(find "$BACKUP_DIR" -name "*.tar.gz" -mtime "+$days" -print0 2>/dev/null)

    # Clean data files
    while IFS= read -r -d '' file; do
        rm "$file"
        ((cleaned_count++))
    done < <(find "$BACKUP_DIR" -name "*.json" -mtime "+$days" -print0 2>/dev/null)

    if [[ $cleaned_count -gt 0 ]]; then
        log_success "Cleaned $cleaned_count old backup files"
    else
        log_info "No old backup files found"
    fi
}

# Function to list backups
list_backups() {
    log_info "Available backups:"
    echo

    # List archives
    if find "$BACKUP_DIR" -name "*.tar.gz" -print0 2>/dev/null | grep -q .; then
        echo "Archives:"
        find "$BACKUP_DIR" -name "*.tar.gz" -exec ls -lh {} \; | sort -k6,7
        echo
    fi

    # List data files
    if find "$BACKUP_DIR" -name "*.json" -print0 2>/dev/null | grep -q .; then
        echo "Data backups:"
        find "$BACKUP_DIR" -name "*.json" -exec ls -lh {} \; | sort -k6,7
    fi
}

# Main function
main() {
    case "${1:-}" in
        "data")
            create_data_backup
            ;;
        "full")
            create_full_backup
            ;;
        "clean")
            clean_old_backups "${2:-30}"
            ;;
        "list")
            list_backups
            ;;
        *)
            show_usage
            exit $EXIT_INVALID_ARGS
            ;;
    esac
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
