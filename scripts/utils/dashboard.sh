#!/bin/bash
# Health Dashboard - comprehensive status of all services and tools

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Status indicators
OK="${GREEN}[ok]${NC}"
WARN="${YELLOW}[!!]${NC}"
ERR="${RED}[--]${NC}"
INFO="${BLUE}[..]${NC}"
OFF="${DIM}[  ]${NC}"

# Box drawing character
BOX_H="-"

# Get terminal width
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
[[ $TERM_WIDTH -gt 100 ]] && TERM_WIDTH=100

# Draw horizontal line
draw_line() {
    local char="${1:-$BOX_H}"
    printf '%*s\n' "$TERM_WIDTH" '' | tr ' ' "$char"
}

# Print centered header
print_header() {
    local text="$1"
    local padding=$(( (TERM_WIDTH - ${#text} - 4) / 2 ))
    echo ""
    draw_line "="
    printf "%*s" $padding ""
    echo -e "${BOLD}${CYAN}  $text  ${NC}"
    draw_line "="
}

# Print section header
print_section() {
    echo ""
    echo -e "${BOLD}${MAGENTA}>> $1${NC}"
    draw_line "-"
}

# Print status line
status_line() {
    local name="$1"
    local status="$2"
    local detail="$3"
    printf "  %-20s %s  %s\n" "$name" "$status" "$detail"
}

# =============================================================================
# Service Checks
# =============================================================================

check_1password() {
    print_section "1Password"

    if ! command -v op &>/dev/null; then
        status_line "CLI" "$ERR" "not installed"
        return
    fi

    local version
    version=$(op --version 2>/dev/null)
    status_line "CLI" "$OK" "v$version"

    if op whoami &>/dev/null 2>&1; then
        local account
        account=$(op whoami --format=json 2>/dev/null | jq -r '.email // .user_uuid' 2>/dev/null || echo "authenticated")
        status_line "Auth" "$OK" "$account"

        # Check SSH agent
        if [[ -S "${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
            status_line "SSH Agent" "$OK" "socket active"
        else
            status_line "SSH Agent" "$WARN" "socket not found"
        fi
    else
        status_line "Auth" "$WARN" "not signed in (run: op signin)"
    fi
}

check_aws() {
    print_section "AWS CLI"

    if ! command -v aws &>/dev/null; then
        status_line "CLI" "$ERR" "not installed"
        return
    fi

    local version
    version=$(aws --version 2>&1 | cut -d' ' -f1 | cut -d'/' -f2)
    status_line "CLI" "$OK" "v$version"

    # Check current profile
    local profile="${AWS_PROFILE:-default}"
    status_line "Profile" "$INFO" "$profile"

    # Check auth status
    if aws sts get-caller-identity &>/dev/null 2>&1; then
        local identity
        identity=$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null | rev | cut -d'/' -f1 | rev)
        status_line "Auth" "$OK" "$identity"
    else
        status_line "Auth" "$WARN" "not authenticated (run: aws sso login)"
    fi

    # List profiles
    local profiles
    profiles=$(aws configure list-profiles 2>/dev/null | wc -l | tr -d ' ')
    status_line "Profiles" "$INFO" "$profiles configured"
}

check_infisical() {
    print_section "Infisical"

    if ! command -v infisical &>/dev/null; then
        status_line "CLI" "$ERR" "not installed"
        return
    fi

    local version
    version=$(infisical --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    status_line "CLI" "$OK" "v$version"

    # Check auth (infisical doesn't have a clean way to check)
    if [[ -f "$HOME/.infisical/credentials.json" ]]; then
        status_line "Auth" "$OK" "credentials present"
    else
        status_line "Auth" "$WARN" "not logged in (run: infisical login)"
    fi
}

check_tailscale() {
    print_section "Tailscale"

    if ! command -v tailscale &>/dev/null; then
        status_line "CLI" "$ERR" "not installed"
        return
    fi

    local version
    version=$(tailscale version 2>/dev/null | head -1)
    status_line "CLI" "$OK" "v$version"

    # Check connection status
    local ts_status
    ts_status=$(tailscale status --json 2>/dev/null)

    if [[ -n "$ts_status" ]]; then
        local self_name
        self_name=$(echo "$ts_status" | jq -r '.Self.HostName' 2>/dev/null)
        local self_ip
        self_ip=$(echo "$ts_status" | jq -r '.Self.TailscaleIPs[0]' 2>/dev/null)

        if [[ "$self_name" != "null" && -n "$self_name" ]]; then
            status_line "Connected" "$OK" "$self_name ($self_ip)"
        else
            status_line "Connected" "$WARN" "not connected"
            return
        fi

        # Count peers
        local online
        online=$(echo "$ts_status" | jq '[.Peer[] | select(.Online==true)] | length' 2>/dev/null || echo 0)
        local total
        total=$(echo "$ts_status" | jq '.Peer | length' 2>/dev/null || echo 0)
        status_line "Peers" "$INFO" "$online online / $total total"

        # Check exit nodes
        local exit_nodes
        exit_nodes=$(echo "$ts_status" | jq '[.Peer[] | select(.ExitNode==true or .ExitNodeOption==true)] | length' 2>/dev/null || echo 0)
        if [[ "$exit_nodes" -gt 0 ]]; then
            status_line "Exit Nodes" "$OK" "$exit_nodes available"
        fi
    else
        status_line "Status" "$WARN" "could not get status"
    fi
}

check_ssh() {
    print_section "SSH"

    # Check SSH agent
    if [[ -n "$SSH_AUTH_SOCK" ]]; then
        status_line "Agent" "$OK" "running"

        # Check loaded keys
        local key_count
        key_count=$(ssh-add -l 2>/dev/null | grep -v "no identities" | wc -l | tr -d ' ')
        if [[ "$key_count" -gt 0 ]]; then
            status_line "Keys Loaded" "$OK" "$key_count key(s)"
        else
            status_line "Keys Loaded" "$WARN" "none (run: ssh-add-keys)"
        fi
    else
        status_line "Agent" "$WARN" "not running"
    fi

    # Check key files
    local key_files=()
    [[ -f "$HOME/.ssh/id_ed25519" ]] && key_files+=("id_ed25519")
    [[ -f "$HOME/.ssh/id_rsa" ]] && key_files+=("id_rsa")

    if [[ ${#key_files[@]} -gt 0 ]]; then
        status_line "Key Files" "$OK" "${key_files[*]}"
    else
        status_line "Key Files" "$WARN" "none found"
    fi
}

check_git() {
    print_section "Git"

    if ! command -v git &>/dev/null; then
        status_line "CLI" "$ERR" "not installed"
        return
    fi

    local version
    version=$(git --version | cut -d' ' -f3)
    status_line "CLI" "$OK" "v$version"

    # Check config
    local user_name
    user_name=$(git config --global user.name 2>/dev/null || echo "")
    local user_email
    user_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -n "$user_name" ]]; then
        status_line "User" "$OK" "$user_name <$user_email>"
    else
        status_line "User" "$WARN" "not configured"
    fi

    # Check GitHub token
    if [[ -n "$GITHUB_TOKEN" ]]; then
        status_line "GitHub Token" "$OK" "set"
    else
        status_line "GitHub Token" "$INFO" "not set"
    fi
}

check_chezmoi() {
    print_section "Chezmoi"

    if ! command -v chezmoi &>/dev/null; then
        status_line "CLI" "$ERR" "not installed"
        return
    fi

    local version
    version=$(chezmoi --version | head -1 | cut -d' ' -f3 | tr -d ',')
    status_line "CLI" "$OK" "v$version"

    # Check status
    local changes
    changes=$(chezmoi status 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$changes" -eq 0 ]]; then
        status_line "Status" "$OK" "in sync"
    else
        status_line "Status" "$WARN" "$changes file(s) changed"
    fi

    # Check source directory
    local source_dir
    source_dir=$(chezmoi source-path 2>/dev/null)
    if [[ -d "$source_dir" ]]; then
        status_line "Source" "$OK" "$(basename "$source_dir")"
    fi
}

check_dev_tools() {
    print_section "Development Tools"

    # Node.js
    if command -v node &>/dev/null; then
        status_line "Node.js" "$OK" "$(node --version)"
    else
        status_line "Node.js" "$OFF" "not installed"
    fi

    # Rust
    if command -v rustc &>/dev/null; then
        status_line "Rust" "$OK" "$(rustc --version | cut -d' ' -f2)"
    else
        status_line "Rust" "$OFF" "not installed"
    fi

    # Python
    if command -v python3 &>/dev/null; then
        status_line "Python" "$OK" "$(python3 --version | cut -d' ' -f2)"
    else
        status_line "Python" "$OFF" "not installed"
    fi

    # Go
    if command -v go &>/dev/null; then
        status_line "Go" "$OK" "$(go version | cut -d' ' -f3 | tr -d 'go')"
    else
        status_line "Go" "$OFF" "not installed"
    fi

    # Docker
    if command -v docker &>/dev/null; then
        if docker info &>/dev/null 2>&1; then
            status_line "Docker" "$OK" "running"
        else
            status_line "Docker" "$WARN" "not running"
        fi
    else
        status_line "Docker" "$OFF" "not installed"
    fi
}

check_shell() {
    print_section "Shell"

    status_line "Current" "$INFO" "$SHELL"

    if command -v zsh &>/dev/null; then
        status_line "Zsh" "$OK" "$(zsh --version | head -1 | cut -d' ' -f2)"
    fi

    # Check Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        status_line "Oh My Zsh" "$OK" "installed"
    fi

    # Check startup time (rough estimate)
    if command -v zsh &>/dev/null; then
        local start_time
        start_time=$({ time zsh -i -c exit; } 2>&1 | grep real | awk '{print $2}')
        status_line "Startup" "$INFO" "$start_time"
    fi
}

# =============================================================================
# Summary
# =============================================================================

print_summary() {
    print_section "Quick Actions"

    echo ""
    echo "  If services need attention:"
    echo ""
    echo -e "    ${CYAN}op signin${NC}              # 1Password login"
    echo -e "    ${CYAN}aws sso login${NC}          # AWS SSO login"
    echo -e "    ${CYAN}infisical login${NC}        # Infisical login"
    echo -e "    ${CYAN}sudo tailscale up${NC}      # Connect Tailscale"
    echo -e "    ${CYAN}ssh-add-keys${NC}           # Load SSH keys"
    echo ""
    echo -e "    ${CYAN}make doctor${NC}            # Full health check"
    echo -e "    ${CYAN}make sync${NC}              # Sync dotfiles"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

show_usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Health Dashboard - Show status of all services

Options:
    --all, -a       Show all sections (default)
    --secrets       Show only secrets providers (1Password, AWS, Infisical)
    --network       Show only network services (Tailscale, SSH)
    --dev           Show only development tools
    --quick, -q     Quick summary only
    --watch, -w     Watch mode (refresh every 5s)
    --help, -h      Show this help

EOF
}

main() {
    local mode="all"
    local watch=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all|-a) mode="all" ;;
            --secrets) mode="secrets" ;;
            --network) mode="network" ;;
            --dev) mode="dev" ;;
            --quick|-q) mode="quick" ;;
            --watch|-w) watch=true ;;
            --help|-h) show_usage; exit 0 ;;
            *) echo "Unknown option: $1"; show_usage; exit 1 ;;
        esac
        shift
    done

    run_dashboard() {
        clear 2>/dev/null || true
        print_header "DROO's Dotfiles Dashboard"
        echo -e "  ${DIM}$(date '+%Y-%m-%d %H:%M:%S')${NC}"

        case "$mode" in
            all)
                check_1password
                check_aws
                check_infisical
                check_tailscale
                check_ssh
                check_git
                check_chezmoi
                check_dev_tools
                check_shell
                ;;
            secrets)
                check_1password
                check_aws
                check_infisical
                ;;
            network)
                check_tailscale
                check_ssh
                ;;
            dev)
                check_dev_tools
                check_shell
                ;;
            quick)
                check_1password
                check_aws
                check_tailscale
                check_ssh
                ;;
        esac

        print_summary
    }

    if $watch; then
        while true; do
            run_dashboard
            echo -e "${DIM}Refreshing in 5s... (Ctrl+C to exit)${NC}"
            sleep 5
        done
    else
        run_dashboard
    fi
}

main "$@"
