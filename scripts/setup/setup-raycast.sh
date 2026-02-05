#!/bin/bash
# Raycast settings export/import for dotfiles

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RAYCAST_DIR="$DOTFILES_ROOT/config/raycast"
RAYCONFIG_FILE="$RAYCAST_DIR/raycast.rayconfig"
SETTINGS_JSON="$RAYCAST_DIR/settings.json"

info() { echo "[*] $1"; }
success() { echo "[+] $1"; }
warn() { echo "[!] $1"; }
error() { echo "[-] $1" >&2; }

check_raycast() {
    if [[ -d "/Applications/Raycast.app" ]]; then
        return 0
    fi
    return 1
}

install_raycast() {
    if check_raycast; then
        success "Raycast is installed"
    else
        error "Raycast not found in /Applications"
        info "Install via: brew install --cask raycast"
        exit 1
    fi

    info "Open Raycast and complete initial setup before exporting settings"
}

export_settings() {
    if ! check_raycast; then
        error "Raycast not installed"
        exit 1
    fi

    mkdir -p "$RAYCAST_DIR"

    info "Opening Raycast export dialog..."
    info "Save the .rayconfig file to: $RAYCAST_DIR/"
    info "Tip: use an empty password for unencrypted export (easier diffing)"
    echo ""
    open "raycast://extensions/raycast/raycast/export-settings-data"

    echo ""
    read -rp "Press Enter after saving the .rayconfig file to config/raycast/... "

    if [[ ! -f "$RAYCONFIG_FILE" ]]; then
        # Check if they saved with a different name
        local found
        found="$(find "$RAYCAST_DIR" -name "*.rayconfig" -maxdepth 1 2>/dev/null | head -1)"
        if [[ -n "$found" ]]; then
            mv "$found" "$RAYCONFIG_FILE"
            info "Renamed $(basename "$found") -> raycast.rayconfig"
        else
            error "No .rayconfig file found in $RAYCAST_DIR"
            exit 1
        fi
    fi

    decompress_settings
}

decompress_settings() {
    if [[ ! -f "$RAYCONFIG_FILE" ]]; then
        error "No rayconfig file found at $RAYCONFIG_FILE"
        exit 1
    fi

    info "Decompressing .rayconfig to settings.json..."

    # Try unencrypted first (gzip)
    if gunzip -c "$RAYCONFIG_FILE" > "$SETTINGS_JSON" 2>/dev/null; then
        # Verify it's valid JSON
        if python3 -m json.tool "$SETTINGS_JSON" > /dev/null 2>&1; then
            # Pretty-print for readable diffs
            python3 -m json.tool "$SETTINGS_JSON" > "${SETTINGS_JSON}.tmp"
            mv "${SETTINGS_JSON}.tmp" "$SETTINGS_JSON"
            success "Decompressed to $SETTINGS_JSON (unencrypted)"
            return 0
        fi
    fi

    # Try encrypted with default password
    info "Unencrypted decompress failed, trying encrypted..."
    read -rsp "Export password (or Enter for default '12345678'): " password
    echo ""
    password="${password:-12345678}"

    if openssl enc -d -aes-256-cbc -nosalt -in "$RAYCONFIG_FILE" -k "$password" 2>/dev/null \
        | tail -c +17 | gunzip > "$SETTINGS_JSON" 2>/dev/null; then
        if python3 -m json.tool "$SETTINGS_JSON" > /dev/null 2>&1; then
            python3 -m json.tool "$SETTINGS_JSON" > "${SETTINGS_JSON}.tmp"
            mv "${SETTINGS_JSON}.tmp" "$SETTINGS_JSON"
            success "Decompressed to $SETTINGS_JSON (encrypted)"
            return 0
        fi
    fi

    rm -f "$SETTINGS_JSON"
    error "Failed to decompress .rayconfig"
    warn "Try re-exporting with no password for easier version control"
    exit 1
}

import_settings() {
    if ! check_raycast; then
        error "Raycast not installed"
        exit 1
    fi

    if [[ ! -f "$RAYCONFIG_FILE" ]]; then
        error "No rayconfig file found at $RAYCONFIG_FILE"
        info "Run 'make raycast-export' first"
        exit 1
    fi

    info "Opening Raycast import dialog..."
    info "Select: $RAYCONFIG_FILE"
    echo ""
    open "raycast://extensions/raycast/raycast/import-settings-data"
}

show_status() {
    echo ""
    echo "Raycast Status:"
    echo ""

    if check_raycast; then
        echo "  Installed: /Applications/Raycast.app"
    else
        echo "  Not installed"
        echo "  Run: brew install --cask raycast"
    fi

    if [[ -f "$RAYCONFIG_FILE" ]]; then
        local size
        size="$(du -h "$RAYCONFIG_FILE" | cut -f1 | xargs)"
        echo "  Export: $RAYCONFIG_FILE ($size)"
    else
        echo "  Export: not found"
    fi

    if [[ -f "$SETTINGS_JSON" ]]; then
        local size
        size="$(du -h "$SETTINGS_JSON" | cut -f1 | xargs)"
        echo "  Settings JSON: $SETTINGS_JSON ($size)"
    else
        echo "  Settings JSON: not found"
    fi
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Manage Raycast settings export/import for dotfiles

Commands:
    install     Verify Raycast is installed (default)
    export      Export Raycast settings to config/raycast/
    import      Import Raycast settings from config/raycast/
    status      Show current status
    help        Show this help

EOF
}

main() {
    case "${1:-install}" in
        install)
            install_raycast
            show_status
            ;;
        export)
            export_settings
            show_status
            ;;
        import)
            import_settings
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
