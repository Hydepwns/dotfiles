#!/bin/bash
# SSH key rotation and sync across Tailscale nodes
# Uses 1Password as the source of truth for SSH keys

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh" 2>/dev/null || {
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
}

info() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }

# Configuration
SSH_KEY_NAME="${SSH_KEY_NAME:-id_ed25519}"
OP_VAULT="${OP_VAULT:-Private}"
TAILSCALE_USER="${TAILSCALE_USER:-droo}"

# Tailscale hosts to sync (from SSH config)
TAILSCALE_HOSTS=(
    "bazzite"
    "dappnode-droo"
    "dravado"
    "mini-axol"
    "ovh-solver"
    "ovh-ubuntu1"
    "slcl03-blackknight"
    "turing-node-1"
    "turing-node-2"
    "turing-node-3"
)

# Check prerequisites
check_prerequisites() {
    local missing=()

    command -v op &>/dev/null || missing+=("1Password CLI (op)")
    command -v tailscale &>/dev/null || missing+=("Tailscale")
    command -v ssh-keygen &>/dev/null || missing+=("ssh-keygen")

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing prerequisites: ${missing[*]}"
        exit 1
    fi

    # Check 1Password auth
    if ! op whoami &>/dev/null; then
        error "Not signed in to 1Password. Run: op signin"
        exit 1
    fi

    # Check Tailscale status
    if ! tailscale status &>/dev/null; then
        error "Tailscale not connected. Run: sudo tailscale up"
        exit 1
    fi

    success "Prerequisites check passed"
}

# Generate new SSH key pair
generate_key() {
    local key_path="$HOME/.ssh/${SSH_KEY_NAME}"
    local comment
    comment="${USER}@$(hostname)-$(date +%Y%m%d)"

    info "Generating new SSH key pair..."

    # Backup existing key
    if [[ -f "$key_path" ]]; then
        local backup
        backup="${key_path}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$key_path" "$backup"
        mv "${key_path}.pub" "${backup}.pub"
        warn "Backed up existing key to: $backup"
    fi

    # Generate new key
    ssh-keygen -t ed25519 -C "$comment" -f "$key_path" -N ""

    success "Generated new key: $key_path"
    echo "  Fingerprint: $(ssh-keygen -lf "$key_path" | cut -d' ' -f2)"
}

# Store key in 1Password
store_in_1password() {
    local key_path="$HOME/.ssh/${SSH_KEY_NAME}"
    local pub_key_path="${key_path}.pub"

    info "Storing key in 1Password..."

    local private_key
    private_key=$(cat "$key_path")
    local public_key
    public_key=$(cat "$pub_key_path")
    local fingerprint
    fingerprint=$(ssh-keygen -lf "$key_path" | cut -d' ' -f2)

    # Check if item exists
    if op item get "SSH Key - $SSH_KEY_NAME" --vault "$OP_VAULT" &>/dev/null; then
        info "Updating existing 1Password item..."
        op item edit "SSH Key - $SSH_KEY_NAME" \
            --vault "$OP_VAULT" \
            "private_key=$private_key" \
            "public_key=$public_key" \
            "fingerprint=$fingerprint" \
            "rotated=$(date -Iseconds)"
    else
        info "Creating new 1Password item..."
        op item create \
            --category="SSH Key" \
            --title="SSH Key - $SSH_KEY_NAME" \
            --vault="$OP_VAULT" \
            "private_key=$private_key" \
            "public_key=$public_key" \
            "fingerprint=$fingerprint" \
            "created=$(date -Iseconds)"
    fi

    success "Key stored in 1Password"
}

# Get public key from 1Password
get_public_key() {
    op item get "SSH Key - $SSH_KEY_NAME" --vault "$OP_VAULT" --fields public_key 2>/dev/null
}

# Sync public key to a single host
sync_to_host() {
    local host="$1"
    local user="${2:-$TAILSCALE_USER}"
    local pub_key
    pub_key=$(get_public_key)

    if [[ -z "$pub_key" ]]; then
        error "Could not retrieve public key from 1Password"
        return 1
    fi

    info "Syncing to $host..."

    # Check if host is reachable via Tailscale
    if ! tailscale ping "$host" -c 1 --timeout 5s &>/dev/null; then
        warn "Host $host is not reachable, skipping"
        return 1
    fi

    # Add key to authorized_keys
    # shellcheck disable=SC2029
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new \
        "${user}@${host}" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
        grep -qF '$pub_key' ~/.ssh/authorized_keys 2>/dev/null || \
        echo '$pub_key' >> ~/.ssh/authorized_keys && \
        chmod 600 ~/.ssh/authorized_keys" 2>/dev/null

    if [[ $? -eq 0 ]]; then
        success "Synced to $host"
        return 0
    else
        warn "Failed to sync to $host"
        return 1
    fi
}

# Sync to all Tailscale hosts
sync_all() {
    local pub_key
    pub_key=$(get_public_key)

    if [[ -z "$pub_key" ]]; then
        # Fall back to local key
        pub_key=$(cat "$HOME/.ssh/${SSH_KEY_NAME}.pub" 2>/dev/null)
    fi

    if [[ -z "$pub_key" ]]; then
        error "No public key available"
        exit 1
    fi

    info "Syncing SSH key to ${#TAILSCALE_HOSTS[@]} Tailscale hosts..."
    echo ""

    local succeeded=0
    local failed=0

    for host in "${TAILSCALE_HOSTS[@]}"; do
        if sync_to_host "$host"; then
            ((succeeded++))
        else
            ((failed++))
        fi
    done

    echo ""
    success "Sync complete: $succeeded succeeded, $failed failed"
}

# List current keys on remote hosts
list_remote_keys() {
    info "Listing authorized keys on Tailscale hosts..."
    echo ""

    for host in "${TAILSCALE_HOSTS[@]}"; do
        echo -e "${CYAN}=== $host ===${NC}"

        if tailscale ping "$host" -c 1 --timeout 5s &>/dev/null; then
            # shellcheck disable=SC2029
            ssh -o ConnectTimeout=10 "${TAILSCALE_USER}@${host}" \
                "cat ~/.ssh/authorized_keys 2>/dev/null | while read key; do echo \"  \$key\" | cut -c1-80; done" 2>/dev/null || \
                echo "  (could not read)"
        else
            echo "  (offline)"
        fi
        echo ""
    done
}

# Remove old keys from remote hosts
cleanup_old_keys() {
    local keep_fingerprint
    keep_fingerprint=$(ssh-keygen -lf "$HOME/.ssh/${SSH_KEY_NAME}" 2>/dev/null | cut -d' ' -f2)

    if [[ -z "$keep_fingerprint" ]]; then
        error "Could not get fingerprint of current key"
        exit 1
    fi

    info "Cleaning up old keys (keeping: $keep_fingerprint)..."
    warn "This will remove all other keys from authorized_keys!"

    read -rp "Continue? [y/N] " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0

    local current_pub
    current_pub=$(cat "$HOME/.ssh/${SSH_KEY_NAME}.pub")

    for host in "${TAILSCALE_HOSTS[@]}"; do
        info "Cleaning $host..."

        if tailscale ping "$host" -c 1 --timeout 5s &>/dev/null; then
            # shellcheck disable=SC2029
            ssh -o ConnectTimeout=10 "${TAILSCALE_USER}@${host}" \
                "echo '$current_pub' > ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" 2>/dev/null && \
                success "Cleaned $host" || warn "Failed to clean $host"
        else
            warn "Host $host offline, skipping"
        fi
    done
}

# Show status
show_status() {
    echo -e "${CYAN}=== SSH Key Rotation Status ===${NC}"
    echo ""

    # Local key
    echo "Local SSH Key:"
    if [[ -f "$HOME/.ssh/${SSH_KEY_NAME}" ]]; then
        echo "  Path: $HOME/.ssh/${SSH_KEY_NAME}"
        echo "  Fingerprint: $(ssh-keygen -lf "$HOME/.ssh/${SSH_KEY_NAME}" | cut -d' ' -f2)"
        echo "  Modified: $(stat -f %Sm -t "%Y-%m-%d %H:%M" "$HOME/.ssh/${SSH_KEY_NAME}" 2>/dev/null || stat -c %y "$HOME/.ssh/${SSH_KEY_NAME}" 2>/dev/null | cut -d'.' -f1)"
    else
        echo "  (not found)"
    fi
    echo ""

    # 1Password
    echo "1Password:"
    if op whoami &>/dev/null; then
        echo "  Status: authenticated"
        if op item get "SSH Key - $SSH_KEY_NAME" --vault "$OP_VAULT" &>/dev/null; then
            echo "  Key stored: yes"
            local rotated
            rotated=$(op item get "SSH Key - $SSH_KEY_NAME" --vault "$OP_VAULT" --fields rotated 2>/dev/null || echo "unknown")
            echo "  Last rotated: $rotated"
        else
            echo "  Key stored: no"
        fi
    else
        echo "  Status: not authenticated"
    fi
    echo ""

    # Tailscale hosts
    echo "Tailscale Hosts:"
    local online=0
    local offline=0
    for host in "${TAILSCALE_HOSTS[@]}"; do
        if tailscale ping "$host" -c 1 --timeout 2s &>/dev/null; then
            echo -e "  ${GREEN}[online]${NC}  $host"
            ((online++))
        else
            echo -e "  ${RED}[offline]${NC} $host"
            ((offline++))
        fi
    done
    echo ""
    echo "  Online: $online, Offline: $offline"
}

# Usage
show_usage() {
    cat <<EOF
Usage: $0 [COMMAND]

SSH key rotation and sync across Tailscale nodes

Commands:
    rotate      Generate new key, store in 1Password, sync to all hosts
    generate    Generate new SSH key pair
    store       Store current key in 1Password
    sync        Sync public key to all Tailscale hosts
    sync-host   Sync to a specific host: $0 sync-host <hostname>
    list        List authorized keys on all remote hosts
    cleanup     Remove old keys from remote hosts (keep only current)
    status      Show current status
    help        Show this help message

Environment Variables:
    SSH_KEY_NAME     Key name (default: id_ed25519)
    OP_VAULT         1Password vault (default: Private)
    TAILSCALE_USER   Remote username (default: droo)

Examples:
    $0 rotate              # Full rotation: generate, store, sync
    $0 sync                # Just sync existing key to all hosts
    $0 sync-host bazzite   # Sync to specific host
    $0 status              # Check current status

EOF
}

# Main
main() {
    case "${1:-status}" in
        rotate)
            check_prerequisites
            generate_key
            store_in_1password
            sync_all
            ;;
        generate)
            generate_key
            ;;
        store)
            check_prerequisites
            store_in_1password
            ;;
        sync)
            check_prerequisites
            sync_all
            ;;
        sync-host)
            check_prerequisites
            [[ -z "$2" ]] && error "Usage: $0 sync-host <hostname>"
            sync_to_host "$2"
            ;;
        list)
            check_prerequisites
            list_remote_keys
            ;;
        cleanup)
            check_prerequisites
            cleanup_old_keys
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
