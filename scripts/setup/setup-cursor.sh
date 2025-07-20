#!/bin/bash
# Setup script for Cursor configuration
# This script installs Cursor settings, keybindings, snippets, and extensions

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../utils/colors.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/../utils/colors.sh"
else
    echo "Warning: colors.sh not found, using fallback colors"
    # Fallback color definitions
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'

    print_status() {
        local status=$1
        local message=$2
        case $status in
            "OK") echo -e "${GREEN}✓${NC} $message" ;;
            "WARN") echo -e "${YELLOW}⚠${NC} $message" ;;
            "ERROR") echo -e "${RED}✗${NC} $message" ;;
            "INFO") echo -e "${BLUE}ℹ${NC} $message" ;;
        esac
    }
fi

# Cursor configuration directories
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
CURSOR_SNIPPETS_DIR="$CURSOR_USER_DIR/snippets"

# Dotfiles configuration directory
DOTFILES_CONFIG_DIR="$(chezmoi source-path)/config/cursor"

echo "🎨 Setting up Cursor configuration"
echo "=================================="

# Check if Cursor is installed
check_cursor_installation() {
    if [[ ! -d "$CURSOR_USER_DIR" ]]; then
        print_status "ERROR" "Cursor is not installed or not found at expected location"
        print_status "INFO" "Please install Cursor from https://cursor.sh"
        return 1
    fi

    print_status "OK" "Cursor installation found"
    return 0
}

# Create Cursor directories
create_cursor_directories() {
    print_status "INFO" "Creating Cursor directories..."

    mkdir -p "$CURSOR_USER_DIR"
    mkdir -p "$CURSOR_SNIPPETS_DIR"

    print_status "OK" "Cursor directories created"
}

# Install Cursor settings
install_cursor_settings() {
    print_status "INFO" "Installing Cursor settings..."

    local settings_source="$DOTFILES_CONFIG_DIR/settings.json.tmpl"
    local settings_target="$CURSOR_USER_DIR/settings.json"

    if [[ -f "$settings_source" ]]; then
        # Use chezmoi to process the template
        cd "$(chezmoi source-path)"
        chezmoi execute-template config/cursor/settings.json.tmpl > "$settings_target"
        print_status "OK" "Cursor settings installed"
    else
        print_status "WARN" "Cursor settings template not found"
    fi
}

# Install Cursor keybindings
install_cursor_keybindings() {
    print_status "INFO" "Installing Cursor keybindings..."

    local keybindings_source="$DOTFILES_CONFIG_DIR/keybindings.json.tmpl"
    local keybindings_target="$CURSOR_USER_DIR/keybindings.json"

    if [[ -f "$keybindings_source" ]]; then
        # Use chezmoi to process the template
        cd "$(chezmoi source-path)"
        chezmoi execute-template config/cursor/keybindings.json.tmpl > "$keybindings_target"
        print_status "OK" "Cursor keybindings installed"
    else
        print_status "WARN" "Cursor keybindings template not found"
    fi
}

# Install Cursor snippets
install_cursor_snippets() {
    print_status "INFO" "Installing Cursor snippets..."

    local snippets_source_dir="$DOTFILES_CONFIG_DIR/snippets"

    if [[ -d "$snippets_source_dir" ]]; then
        for snippet_file in "$snippets_source_dir"/*.json.tmpl; do
            if [[ -f "$snippet_file" ]]; then
                local filename
                filename=$(basename "$snippet_file" .tmpl)
                local target_file="$CURSOR_SNIPPETS_DIR/$filename"

                # Use chezmoi to process the template
                cd "$(chezmoi source-path)"
                chezmoi execute-template "config/cursor/snippets/$filename.tmpl" > "$target_file"
                print_status "OK" "Installed snippet: $filename"
            fi
        done
    else
        print_status "WARN" "Cursor snippets directory not found"
    fi
}

# Install Cursor extensions
install_cursor_extensions() {
    print_status "INFO" "Installing Cursor extensions..."

    local extensions_source="$DOTFILES_CONFIG_DIR/extensions.json.tmpl"
    local extensions_target="$CURSOR_USER_DIR/extensions.json"

    if [[ -f "$extensions_source" ]]; then
        # Use chezmoi to process the template
        cd "$(chezmoi source-path)"
        chezmoi execute-template config/cursor/extensions.json.tmpl > "$extensions_target"
        print_status "OK" "Cursor extensions configuration installed"
        print_status "INFO" "Please install recommended extensions from Cursor's extension marketplace"
    else
        print_status "WARN" "Cursor extensions template not found"
    fi
}

# Backup existing Cursor configuration
backup_existing_config() {
    print_status "INFO" "Backing up existing Cursor configuration..."

    local backup_dir="$HOME/.local/share/chezmoi/backups/cursor"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    mkdir -p "$backup_dir"

    # Backup settings
    if [[ -f "$CURSOR_USER_DIR/settings.json" ]]; then
        cp "$CURSOR_USER_DIR/settings.json" "$backup_dir/settings_${timestamp}.json"
        print_status "OK" "Backed up settings.json"
    fi

    # Backup keybindings
    if [[ -f "$CURSOR_USER_DIR/keybindings.json" ]]; then
        cp "$CURSOR_USER_DIR/keybindings.json" "$backup_dir/keybindings_${timestamp}.json"
        print_status "OK" "Backed up keybindings.json"
    fi

    # Backup snippets
    if [[ -d "$CURSOR_SNIPPETS_DIR" ]] && [[ "$(ls -A "$CURSOR_SNIPPETS_DIR")" ]]; then
        cp -r "$CURSOR_SNIPPETS_DIR" "$backup_dir/snippets_${timestamp}"
        print_status "OK" "Backed up snippets directory"
    fi
}

# Verify Cursor configuration
verify_cursor_config() {
    print_status "INFO" "Verifying Cursor configuration..."

    local issues=()

    # Check settings
    if [[ ! -f "$CURSOR_USER_DIR/settings.json" ]]; then
        issues+=("settings.json not found")
    fi

    # Check keybindings
    if [[ ! -f "$CURSOR_USER_DIR/keybindings.json" ]]; then
        issues+=("keybindings.json not found")
    fi

    # Check snippets directory
    if [[ ! -d "$CURSOR_SNIPPETS_DIR" ]]; then
        issues+=("snippets directory not found")
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        print_status "WARN" "Configuration issues found:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        return 1
    else
        print_status "OK" "Cursor configuration verified successfully"
        return 0
    fi
}

# Main execution
main() {
    if ! check_cursor_installation; then
        exit 1
    fi

    backup_existing_config
    create_cursor_directories
    install_cursor_settings
    install_cursor_keybindings
    install_cursor_snippets
    install_cursor_extensions
    verify_cursor_config

    echo ""
    echo "✅ Cursor configuration setup complete!"
    echo "========================================"
    echo "Next steps:"
    echo "1. Restart Cursor to apply the new configuration"
    echo "2. Install recommended extensions from the extensions marketplace"
    echo "3. Customize settings as needed"
    echo ""
    echo "Configuration files:"
    echo "  - Settings: $CURSOR_USER_DIR/settings.json"
    echo "  - Keybindings: $CURSOR_USER_DIR/keybindings.json"
    echo "  - Snippets: $CURSOR_SNIPPETS_DIR/"
    echo "  - Extensions: $CURSOR_USER_DIR/extensions.json"
}

# Run main function
main "$@"
