#!/bin/bash
# Centralized configuration management for DROO's dotfiles

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/colors.sh"

# Configuration file locations (using functions for compatibility)
get_config_file() {
    local config_type="$1"
    case "$config_type" in
        "chezmoi") echo "$HOME/.config/chezmoi/chezmoi.toml" ;;
        "git") echo "$HOME/.gitconfig" ;;
        "zsh") echo "$HOME/.zshrc" ;;
        "ssh") echo "$HOME/.ssh/config" ;;
        "tmux") echo "$HOME/.tmux.conf" ;;
        "nvim") echo "$HOME/.config/nvim/init.lua" ;;
        "kitty") echo "$HOME/.config/kitty/kitty.conf" ;;
        "ghostty") echo "$HOME/Library/Application Support/com.mitchellh.ghostty/config" ;;
        "aws") echo "$HOME/.aws/config" ;;
        "zed") echo "$HOME/.config/zed/settings.json" ;;
        *) echo "" ;;
    esac
}

# Configuration validation
validate_config() {
    local config_type="$1"
    local config_file
    config_file=$(get_config_file "$config_type")

    if [[ -z "$config_file" ]]; then
        log_error "Unknown config type: $config_type"
        return $EXIT_INVALID_ARGS
    fi

    if [[ ! -f "$config_file" ]]; then
        log_warning "Config file not found: $config_file"
        return $EXIT_FILE_NOT_FOUND
    fi

    return $EXIT_SUCCESS
}

# Get configuration value
get_config_value() {
    local config_type="$1"
    local key="$2"

    if ! validate_config "$config_type"; then
        return $?
    fi

    local config_file
    config_file=$(get_config_file "$config_type")

    case "$config_type" in
        "git")
            git config --global --get "$key" 2>/dev/null || echo ""
            ;;
        "chezmoi")
            # Parse chezmoi config (simplified)
            grep "^$key" "$config_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "' || echo ""
            ;;
        "zsh")
            # Extract variable from zsh config
            grep "^export $key=" "$config_file" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo ""
            ;;
        *)
            log_error "Unsupported config type: $config_type"
            return $EXIT_INVALID_ARGS
            ;;
    esac
}

# Set configuration value
set_config_value() {
    local config_type="$1"
    local key="$2"
    local value="$3"

    if ! validate_config "$config_type"; then
        return $?
    fi

    local config_file
    config_file=$(get_config_file "$config_type")

    case "$config_type" in
        "git")
            git config --global "$key" "$value"
            ;;
        "chezmoi")
            # Update chezmoi config (backup first)
            backup_file "$config_file"
            sed -i.bak "s/^$key=.*/$key=$value/" "$config_file"
            ;;
        *)
            log_error "Unsupported config type: $config_type"
            return $EXIT_INVALID_ARGS
            ;;
    esac
}

# List all configuration files
list_configs() {
    echo "Available configuration files:"
    local config_types=("chezmoi" "git" "zsh" "ssh" "tmux" "nvim" "kitty" "ghostty" "aws" "zed")

    for config_type in "${config_types[@]}"; do
        local config_file
        config_file=$(get_config_file "$config_type")
        local status=""

        if [[ -f "$config_file" ]]; then
            status="[ok]"
        else
            status="[--]"
        fi

        printf "  %-15s %s %s\n" "$config_type" "$status" "$config_file"
    done
}

# Check configuration health
check_config_health() {
    local issues=()

    local config_types=("chezmoi" "git" "zsh" "ssh" "tmux" "nvim" "kitty" "ghostty" "aws" "zed")

    for config_type in "${config_types[@]}"; do
        local config_file
        config_file=$(get_config_file "$config_type")

        if [[ ! -f "$config_file" ]]; then
            issues+=("$config_type: File not found")
        elif [[ ! -r "$config_file" ]]; then
            issues+=("$config_type: File not readable")
        fi
    done

    if [[ ${#issues[@]} -gt 0 ]]; then
        log_warning "Configuration issues found:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        return $EXIT_FAILURE
    else
        log_success "All configuration files are healthy"
        return $EXIT_SUCCESS
    fi
}

# Backup configuration
backup_config() {
    local config_type="$1"
    local backup_dir="$BACKUP_DIR/configs"

    if ! validate_config "$config_type"; then
        return $?
    fi

    local config_file
    config_file=$(get_config_file "$config_type")
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/${config_type}_${timestamp}.backup"

    ensure_dir "$backup_dir"

    if cp "$config_file" "$backup_file"; then
        log_success "Backed up $config_type to $backup_file"
        return $EXIT_SUCCESS
    else
        log_error "Failed to backup $config_type"
        return $EXIT_FAILURE
    fi
}

# Restore configuration
restore_config() {
    local config_type="$1"
    local backup_file="$2"

    if ! validate_config "$config_type"; then
        return $?
    fi

    local config_file
    config_file=$(get_config_file "$config_type")

    if [[ ! -f "$backup_file" ]]; then
        log_error "Backup file not found: $backup_file"
        return $EXIT_FILE_NOT_FOUND
    fi

    # Backup current config before restoring
    backup_config "$config_type"

    if cp "$backup_file" "$config_file"; then
        log_success "Restored $config_type from $backup_file"
        return $EXIT_SUCCESS
    else
        log_error "Failed to restore $config_type"
        return $EXIT_FAILURE
    fi
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Configuration management for DROO's dotfiles

Commands:
    list                    List all configuration files
    get <type> <key>        Get configuration value
    set <type> <key> <value> Set configuration value
    validate <type>         Validate configuration file
    health                  Check health of all configurations
    backup <type>           Backup configuration file
    restore <type> <file>   Restore configuration from backup

Examples:
    $0 list
    $0 get git user.name
    $0 set git user.name "John Doe"
    $0 health
    $0 backup git

EOF
}

# Main function
main() {
    case "${1:-}" in
        "list")
            list_configs
            ;;
        "get")
            if [[ $# -lt 3 ]]; then
                log_error "Usage: $0 get <type> <key>"
                exit $EXIT_INVALID_ARGS
            fi
            get_config_value "$2" "$3"
            ;;
        "set")
            if [[ $# -lt 4 ]]; then
                log_error "Usage: $0 set <type> <key> <value>"
                exit $EXIT_INVALID_ARGS
            fi
            set_config_value "$2" "$3" "$4"
            ;;
        "validate")
            if [[ $# -lt 2 ]]; then
                log_error "Usage: $0 validate <type>"
                exit $EXIT_INVALID_ARGS
            fi
            validate_config "$2"
            ;;
        "health")
            check_config_health
            ;;
        "backup")
            if [[ $# -lt 2 ]]; then
                log_error "Usage: $0 backup <type>"
                exit $EXIT_INVALID_ARGS
            fi
            backup_config "$2"
            ;;
        "restore")
            if [[ $# -lt 3 ]]; then
                log_error "Usage: $0 restore <type> <backup_file>"
                exit $EXIT_INVALID_ARGS
            fi
            restore_config "$2" "$3"
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
