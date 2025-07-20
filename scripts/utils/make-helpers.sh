#!/bin/bash
# Makefile helper functions for DROO's dotfiles

# Common make targets with descriptions
declare -A MAKE_TARGETS=(
    ["install"]="Install dotfiles using chezmoi"
    ["update"]="Update dotfiles from remote repository"
    ["diff"]="Show differences between current and target state"
    ["status"]="Show status of dotfiles"
    ["backup"]="Create backup of current dotfiles"
    ["backup-full"]="Create full backup with archive"
    ["clean"]="Clean up temporary files and backups"
    ["doctor"]="Run health check on dotfiles setup"
    ["bootstrap"]="Run bootstrap script for fresh installation"
    ["sync"]="Sync local changes to repository"
    ["sync-from-remote"]="Sync from remote repository"
    ["install-optional"]="Install optional tools interactively"
    ["performance-test"]="Run performance tests"
    ["generate-template"]="Generate project template"
    ["tool-versions"]="Manage tool versions"
)

# Function to print help
print_make_help() {
    echo "Available commands:"
    for target in "${!MAKE_TARGETS[@]}"; do
        local desc="${MAKE_TARGETS[$target]}"
        printf "  %-20s - %s\n" "$target" "$desc"
    done
}

# Function to run script with error handling
run_script() {
    local script="$1"
    local args="$2"
    
    if [[ -f "$script" ]]; then
        chmod +x "$script"
        ./"$script" "$args"
    else
        echo "Script not found: $script"
        return 1
    fi
}

# Function to check if script exists
script_exists() {
    local script="$1"
    [[ -f "$script" ]]
}

# Function to create backup with timestamp
create_backup() {
    local backup_type="$1"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir="backups"
    
    mkdir -p "$backup_dir"
    
    case "$backup_type" in
        "data")
            chezmoi data > "$backup_dir/chezmoi-data-$timestamp.json"
            echo "Data backup created: $backup_dir/chezmoi-data-$timestamp.json"
            ;;
        "full")
            chezmoi archive --output "$backup_dir/dotfiles-$timestamp.tar.gz"
            chezmoi data > "$backup_dir/chezmoi-data-$timestamp.json"
            echo "Full backup created: $backup_dir/dotfiles-$timestamp.tar.gz"
            ;;
        *)
            echo "Unknown backup type: $backup_type"
            return 1
            ;;
    esac
}

# Function to clean old backups
clean_old_backups() {
    local days="${1:-30}"
    echo "Cleaning backups older than $days days..."
    find backups -name "*.tar.gz" -mtime "+$days" -delete 2>/dev/null || true
    find backups -name "*.json" -mtime "+$days" -delete 2>/dev/null || true
}

# Function to prompt for confirmation
confirm_action() {
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
    elif [[ -z $REPLY ]]; then
        [[ "$default" == "y" ]]
    else
        return 1
    fi
}

# Function to install optional tool
install_optional_tool() {
    local tool="$1"
    local package="$2"
    
    read -p "Install $tool? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            brew install "$package"
            echo "$tool installed successfully"
        else
            echo "Homebrew not found. Please install $tool manually."
        fi
    fi
}

# Function to show template help
show_template_help() {
    echo "Template generator for DROO's dotfiles"
    echo "Usage: make generate-template TEMPLATE=<type> NAME=<project-name>"
    echo ""
    echo "Available templates:"
    echo "  web3    - Ethereum/Solana smart contract project"
    echo "  nextjs  - Next.js with TypeScript and Tailwind"
    echo "  rust    - Rust project with common dependencies"
    echo "  elixir  - Elixir Phoenix project"
    echo ""
    echo "Example: make generate-template TEMPLATE=web3 NAME=my-defi-project"
}

# Function to show tool versions help
show_tool_versions_help() {
    echo "Tool version management for DROO's dotfiles"
    echo "Usage: make tool-versions COMMAND=<command>"
    echo ""
    echo "Available commands:"
    echo "  update   - Update .tool-versions with current installed versions"
    echo "  check    - Check for outdated tools"
    echo "  install  - Install missing tools using asdf"
    echo "  list     - List all tools and their versions"
    echo ""
    echo "Example: make tool-versions COMMAND=update"
} 