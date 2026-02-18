#!/bin/bash
# Age encryption key management for chezmoi dotfiles
# Handles: key generation, 1Password backup, retrieval on new machines

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../utils/logging.sh
source "$DOTFILES_ROOT/scripts/utils/logging.sh"

# shellcheck source=../utils/constants.sh
source "$DOTFILES_ROOT/scripts/utils/constants.sh" 2>/dev/null || true

AGE_KEY_PATH="$HOME/.config/chezmoi/age_key.txt"
OP_ITEM_TITLE="${OP_AGE_ITEM:-Dotfiles Age Key}"

# =============================================================================
# Generate
# =============================================================================

generate() {
    if [[ -f "$AGE_KEY_PATH" ]]; then
        log_info "Age key already exists at $AGE_KEY_PATH"
        local pubkey
        pubkey=$(grep -oP 'public key: \K.*' "$AGE_KEY_PATH" 2>/dev/null || true)
        if [[ -n "$pubkey" ]]; then
            log_info "Public key: $pubkey"
        fi
        return 0
    fi

    if ! command -v age-keygen &>/dev/null; then
        log_error "age not installed. Run: brew install age"
        return 1
    fi

    mkdir -p "$(dirname "$AGE_KEY_PATH")"
    age-keygen -o "$AGE_KEY_PATH" 2>&1
    chmod 600 "$AGE_KEY_PATH"
    log_success "Age key generated at $AGE_KEY_PATH"
    log_info "Add the public key above to chezmoi.toml [age] recipient"
}

# =============================================================================
# Backup to 1Password
# =============================================================================

backup() {
    if [[ ! -f "$AGE_KEY_PATH" ]]; then
        log_error "No age key found at $AGE_KEY_PATH"
        log_info "Run: $0 generate"
        return 1
    fi

    if ! command -v op &>/dev/null; then
        log_error "1Password CLI not installed"
        return 1
    fi

    if ! op whoami &>/dev/null 2>&1; then
        log_error "Not signed in to 1Password. Run: op signin"
        return 1
    fi

    local key_content
    key_content=$(cat "$AGE_KEY_PATH")

    if op item get "$OP_ITEM_TITLE" --vault "$OP_VAULT" &>/dev/null 2>&1; then
        log_info "Updating existing 1Password item..."
        op item edit "$OP_ITEM_TITLE" --vault "$OP_VAULT" \
            "notesPlain=$key_content" &>/dev/null
    else
        log_info "Creating 1Password item..."
        op item create --category "Secure Note" \
            --title "$OP_ITEM_TITLE" \
            --vault "$OP_VAULT" \
            "notesPlain=$key_content" &>/dev/null
    fi

    log_success "Age key backed up to 1Password ($OP_VAULT/$OP_ITEM_TITLE)"
}

# =============================================================================
# Retrieve from 1Password
# =============================================================================

retrieve() {
    if [[ -f "$AGE_KEY_PATH" ]]; then
        log_info "Age key already exists at $AGE_KEY_PATH"
        return 0
    fi

    if ! command -v op &>/dev/null; then
        log_error "1Password CLI not installed"
        return 1
    fi

    if ! op whoami &>/dev/null 2>&1; then
        log_error "Not signed in to 1Password. Run: op signin"
        return 1
    fi

    local key_content
    key_content=$(op item get "$OP_ITEM_TITLE" --vault "$OP_VAULT" --fields notesPlain 2>/dev/null)

    if [[ -z "$key_content" ]]; then
        log_error "Age key not found in 1Password ($OP_VAULT/$OP_ITEM_TITLE)"
        return 1
    fi

    mkdir -p "$(dirname "$AGE_KEY_PATH")"
    printf '%s\n' "$key_content" > "$AGE_KEY_PATH"
    chmod 600 "$AGE_KEY_PATH"
    log_success "Age key retrieved from 1Password to $AGE_KEY_PATH"
}

# =============================================================================
# Status
# =============================================================================

status() {
    echo "Age Encryption Status:"
    echo ""

    # age CLI
    if command -v age &>/dev/null; then
        printf "  %-20s %s\n" "age CLI:" "installed ($(age --version 2>&1 || echo 'unknown'))"
    else
        printf "  %-20s %s\n" "age CLI:" "not installed"
    fi

    # Key file
    if [[ -f "$AGE_KEY_PATH" ]]; then
        local perms
        perms=$(stat -f '%Lp' "$AGE_KEY_PATH" 2>/dev/null || stat -c '%a' "$AGE_KEY_PATH" 2>/dev/null)
        printf "  %-20s %s\n" "Key file:" "$AGE_KEY_PATH (mode: $perms)"

        local pubkey
        pubkey=$(grep -oP 'public key: \K.*' "$AGE_KEY_PATH" 2>/dev/null || true)
        if [[ -n "$pubkey" ]]; then
            printf "  %-20s %s\n" "Public key:" "$pubkey"
        fi
    else
        printf "  %-20s %s\n" "Key file:" "not found"
    fi

    # 1Password backup
    if command -v op &>/dev/null && op whoami &>/dev/null 2>&1; then
        if op item get "$OP_ITEM_TITLE" --vault "$OP_VAULT" &>/dev/null 2>&1; then
            printf "  %-20s %s\n" "1Password backup:" "exists ($OP_VAULT/$OP_ITEM_TITLE)"
        else
            printf "  %-20s %s\n" "1Password backup:" "not found"
        fi
    else
        printf "  %-20s %s\n" "1Password backup:" "not checked (not signed in)"
    fi

    echo ""
}

# =============================================================================
# Main
# =============================================================================

show_usage() {
    cat <<EOF
Usage: $0 [COMMAND]

Manage age encryption key for chezmoi dotfiles

Commands:
    generate    Generate age key if none exists
    backup      Back up age key to 1Password
    retrieve    Retrieve age key from 1Password (new machine)
    status      Show age encryption status
    help        Show this help message

EOF
}

main() {
    case "${1:-help}" in
        generate)
            generate
            ;;
        backup)
            backup
            ;;
        retrieve)
            retrieve
            ;;
        status)
            status
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
