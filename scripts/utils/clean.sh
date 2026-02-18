#!/usr/bin/env bash
# Clean utility for DROO's dotfiles

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=simple-init.sh
source "$SCRIPT_DIR/simple-init.sh"

# Configuration
BACKUP_DIR="$DOTFILES_ROOT/backups"
mkdir -p "$BACKUP_DIR"

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    --backups <days>    Clean backups older than <days> (default: 30)
    --temp              Clean temporary files only
    --all               Clean everything (temp files and old backups)
    --dry-run           Show what would be cleaned without actually cleaning

Examples:
    $0 --all
    $0 --backups 7
    $0 --temp --dry-run

EOF
}

# Function to clean temporary files
clean_temp_files() {
    local dry_run="${1:-false}"
    local cleaned_count=0

    log_info "Cleaning temporary files..."

    # Patterns to clean
    local patterns=(
        "*.bak"
        "*.tmp"
        "*.swp"
        "*.swo"
        "*~"
        ".DS_Store"
        "Thumbs.db"
    )

    for pattern in "${patterns[@]}"; do
        while IFS= read -r -d '' file; do
            if [[ "$dry_run" == "true" ]]; then
                echo "Would remove: $file"
            else
                rm "$file"
                log_debug "Removed: $file"
            fi
            ((cleaned_count++))
        done < <(find . -name "$pattern" -print0 2>/dev/null)
    done

    if [[ $cleaned_count -gt 0 ]]; then
        if [[ "$dry_run" == "true" ]]; then
            log_info "Would clean $cleaned_count temporary files"
        else
            log_success "Cleaned $cleaned_count temporary files"
        fi
    else
        log_info "No temporary files found"
    fi

    return $cleaned_count
}

# Function to clean old backups
clean_old_backups() {
    local days
    days="${1:-30}"
    local dry_run
    dry_run="${2:-false}"
    local cleaned_count
    cleaned_count=0

    log_info "Cleaning backups older than $days days..."

    # Clean archives
    while IFS= read -r -d '' file; do
        if [[ "$dry_run" == "true" ]]; then
            echo "Would remove: $file"
        else
            rm "$file"
            log_debug "Removed: $file"
        fi
        ((cleaned_count++))
    done < <(find "$BACKUP_DIR" -name "*.tar.gz" -mtime "+$days" -print0 2>/dev/null)

    # Clean data files
    while IFS= read -r -d '' file; do
        if [[ "$dry_run" == "true" ]]; then
            echo "Would remove: $file"
        else
            rm "$file"
            log_debug "Removed: $file"
        fi
        ((cleaned_count++))
    done < <(find "$BACKUP_DIR" -name "*.json" -mtime "+$days" -print0 2>/dev/null)

    if [[ $cleaned_count -gt 0 ]]; then
        if [[ "$dry_run" == "true" ]]; then
            log_info "Would clean $cleaned_count old backup files"
        else
            log_success "Cleaned $cleaned_count old backup files"
        fi
    else
        log_info "No old backup files found"
    fi

    return $cleaned_count
}

# Function to clean everything
clean_all() {
    local dry_run="${1:-false}"
    local total_cleaned
    total_cleaned=0

    log_info "Cleaning everything..."

    # Clean temp files
    local temp_cleaned
    temp_cleaned=$(clean_temp_files "$dry_run")
    total_cleaned=$((total_cleaned + temp_cleaned))

    # Clean old backups
    local backup_cleaned
    backup_cleaned=$(clean_old_backups 30 "$dry_run")
    total_cleaned=$((total_cleaned + backup_cleaned))

    if [[ $total_cleaned -gt 0 ]]; then
        if [[ "$dry_run" == "true" ]]; then
            log_info "Would clean $total_cleaned files total"
        else
            log_success "Cleaned $total_cleaned files total"
        fi
    else
        log_info "No files to clean"
    fi
}

# Function to parse arguments
parse_args() {
    local dry_run=false
    local clean_type=""
    local backup_days=30

    while [[ $# -gt 0 ]]; do
        case $1 in
            --backups)
                backup_days="$2"
                shift 2
                ;;
            --temp)
                clean_type="temp"
                shift
                ;;
            --all)
                clean_type="all"
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -h|--help)
                show_usage
                exit $EXIT_SUCCESS
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit $EXIT_INVALID_ARGS
                ;;
        esac
    done

    echo "$clean_type:$backup_days:$dry_run"
}

# Main function
main() {
    local args
    args=("$(parse_args "$@")")

    IFS=':' read -r clean_type backup_days dry_run <<< "${args[0]}"

    case "$clean_type" in
        "temp")
            clean_temp_files "$dry_run"
            ;;
        "all")
            clean_all "$dry_run"
            ;;
        "")
            # Default: clean temp files and old backups
            clean_temp_files "$dry_run"
            clean_old_backups "$backup_days" "$dry_run"
            ;;
        *)
            log_error "Invalid clean type: $clean_type"
            show_usage
            exit $EXIT_INVALID_ARGS
            ;;
    esac
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
