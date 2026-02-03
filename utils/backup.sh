#!/usr/bin/env bash

# Simple Backup Script - No dependencies, no segfaults!

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BACKUP_DIR="${BACKUP_DIR:-$DOTFILES_DIR/backups}"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to show usage
show_usage() {
    echo "Usage: $0 [data|full|config]"
    echo ""
    echo "Backup types:"
    echo "  data   - Backup chezmoi data only"
    echo "  full   - Full dotfiles archive"
    echo "  config - Backup configuration files"
    echo ""
    echo "Default: data"
}

# Function to create data backup
backup_data() {
    echo -e "${YELLOW}Creating data backup...${NC}"
    
    # Backup chezmoi data if it exists
    if command -v chezmoi >/dev/null 2>&1; then
        local backup_file="$BACKUP_DIR/chezmoi-data-${TIMESTAMP}.json"
        
        if chezmoi data > "$backup_file" 2>/dev/null; then
            echo -e "${GREEN}✓ Chezmoi data backed up to: $backup_file${NC}"
        else
            echo -e "${RED}✗ Failed to backup chezmoi data${NC}"
            rm -f "$backup_file"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ Chezmoi not found, skipping data backup${NC}"
    fi
    
    # Backup git config
    if [ -f ~/.gitconfig ]; then
        cp ~/.gitconfig "$BACKUP_DIR/gitconfig-${TIMESTAMP}"
        echo -e "${GREEN}✓ Git config backed up${NC}"
    fi
    
    return 0
}

# Function to create full backup
backup_full() {
    echo -e "${YELLOW}Creating full backup...${NC}"
    
    local archive_name="dotfiles-${TIMESTAMP}.tar.gz"
    local archive_path="$BACKUP_DIR/$archive_name"
    
    # Create archive excluding certain directories
    tar czf "$archive_path" \
        --exclude="$BACKUP_DIR" \
        --exclude=".git" \
        --exclude="node_modules" \
        --exclude=".cache" \
        --exclude="*.log" \
        -C "$(dirname "$DOTFILES_DIR")" \
        "$(basename "$DOTFILES_DIR")" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        local size=$(du -h "$archive_path" | cut -f1)
        echo -e "${GREEN}✓ Full backup created: $archive_path ($size)${NC}"
    else
        echo -e "${RED}✗ Failed to create full backup${NC}"
        return 1
    fi
}

# Function to backup config files
backup_config() {
    echo -e "${YELLOW}Backing up configuration files...${NC}"
    
    local config_backup="$BACKUP_DIR/configs-${TIMESTAMP}"
    mkdir -p "$config_backup"
    
    # List of config files to backup
    local configs=(
        ~/.zshrc
        ~/.gitconfig
        ~/.tmux.conf
        ~/.config/chezmoi/chezmoi.toml
    )
    
    local backed_up=0
    for config in "${configs[@]}"; do
        if [ -f "$config" ]; then
            cp "$config" "$config_backup/$(basename "$config")"
            echo -e "${GREEN}✓ Backed up: $(basename "$config")${NC}"
            ((backed_up++))
        fi
    done
    
    echo -e "${GREEN}✓ Backed up $backed_up configuration files to: $config_backup${NC}"
}

# Function to list existing backups
list_backups() {
    echo -e "${YELLOW}Existing backups:${NC}"
    echo "----------------"
    
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        ls -lah "$BACKUP_DIR" | grep -E "\.(tar\.gz|json|toml)$|gitconfig-|configs-" | tail -10
        echo ""
        echo "Total: $(find "$BACKUP_DIR" -type f | wc -l) backup files"
        echo "Size: $(du -sh "$BACKUP_DIR" | cut -f1)"
    else
        echo "No backups found"
    fi
}

# Main execution
main() {
    local backup_type="${1:-data}"
    
    case "$backup_type" in
        data)
            backup_data
            ;;
        full)
            backup_full
            ;;
        config)
            backup_config
            ;;
        list)
            list_backups
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown backup type '$backup_type'${NC}"
            show_usage
            exit 1
            ;;
    esac
    
    # Show summary
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}Backup completed successfully!${NC}"
        echo "Backup directory: $BACKUP_DIR"
    fi
}

# Run main function
main "$@"