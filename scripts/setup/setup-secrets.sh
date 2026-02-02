#!/bin/bash
# Secrets management tools setup for DROO's dotfiles
# Installs: 1Password CLI, AWS CLI, Infisical

set -e

log_info() { echo "[INFO] $1"; }
log_success() { echo "[OK] $1"; }
log_error() { echo "[ERROR] $1" >&2; }

# =============================================================================
# 1Password CLI
# =============================================================================

install_1password() {
    if command -v op &>/dev/null; then
        log_info "1Password CLI already installed: $(op --version)"
        return 0
    fi

    local os_type
    os_type="$(uname -s)"

    case "$os_type" in
        Darwin)
            if command -v brew &>/dev/null; then
                log_info "Installing 1Password CLI via Homebrew..."
                brew install --cask 1password-cli
            else
                log_error "Homebrew not found. Install from https://1password.com/downloads/command-line/"
                return 1
            fi
            ;;
        Linux)
            log_info "Installing 1Password CLI..."
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
                sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
                sudo tee /etc/apt/sources.list.d/1password.list
            sudo apt update && sudo apt install -y 1password-cli
            ;;
        *)
            log_error "Unsupported OS: $os_type"
            return 1
            ;;
    esac

    log_success "1Password CLI installed"
}

# =============================================================================
# AWS CLI
# =============================================================================

install_aws() {
    if command -v aws &>/dev/null; then
        log_info "AWS CLI already installed: $(aws --version | cut -d' ' -f1)"
        return 0
    fi

    local os_type
    os_type="$(uname -s)"

    case "$os_type" in
        Darwin)
            if command -v brew &>/dev/null; then
                log_info "Installing AWS CLI via Homebrew..."
                brew install awscli
            else
                log_info "Installing AWS CLI via pkg..."
                curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
                sudo installer -pkg AWSCLIV2.pkg -target /
                rm AWSCLIV2.pkg
            fi
            ;;
        Linux)
            log_info "Installing AWS CLI..."
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip -q awscliv2.zip
            sudo ./aws/install
            rm -rf aws awscliv2.zip
            ;;
        *)
            log_error "Unsupported OS: $os_type"
            return 1
            ;;
    esac

    log_success "AWS CLI installed"
}

# =============================================================================
# Infisical
# =============================================================================

install_infisical() {
    if command -v infisical &>/dev/null; then
        log_info "Infisical already installed: $(infisical --version)"
        return 0
    fi

    local os_type
    os_type="$(uname -s)"

    case "$os_type" in
        Darwin)
            if command -v brew &>/dev/null; then
                log_info "Installing Infisical via Homebrew..."
                brew install infisical/get-cli/infisical
            else
                log_error "Homebrew not found"
                return 1
            fi
            ;;
        Linux)
            log_info "Installing Infisical..."
            curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
            sudo apt update && sudo apt install -y infisical
            ;;
        *)
            log_error "Unsupported OS: $os_type"
            return 1
            ;;
    esac

    log_success "Infisical installed"
}

# =============================================================================
# Tailscale (included for completeness)
# =============================================================================

install_tailscale() {
    if command -v tailscale &>/dev/null; then
        log_info "Tailscale already installed: $(tailscale version | head -1)"
        return 0
    fi

    local os_type
    os_type="$(uname -s)"

    case "$os_type" in
        Darwin)
            if command -v brew &>/dev/null; then
                log_info "Installing Tailscale via Homebrew..."
                brew install --cask tailscale
            else
                log_error "Homebrew not found. Install from https://tailscale.com/download/mac"
                return 1
            fi
            ;;
        Linux)
            log_info "Installing Tailscale..."
            curl -fsSL https://tailscale.com/install.sh | sh
            ;;
        *)
            log_error "Unsupported OS: $os_type"
            return 1
            ;;
    esac

    log_success "Tailscale installed"
}

# =============================================================================
# Configuration
# =============================================================================

configure_1password() {
    echo ""
    echo "1Password CLI configuration:"
    echo "  1. Sign in: op signin"
    echo "  2. Enable SSH agent in 1Password app settings"
    echo "  3. Add SSH keys to 1Password"
    echo ""
}

configure_aws() {
    local aws_dir="$HOME/.aws"

    if [[ ! -d "$aws_dir" ]]; then
        mkdir -p "$aws_dir"
        chmod 700 "$aws_dir"
    fi

    if [[ ! -f "$aws_dir/config" ]]; then
        cat > "$aws_dir/config" <<'EOF'
[default]
region = us-east-1
output = json

# Add SSO profiles:
# [profile my-sso-profile]
# sso_start_url = https://my-org.awsapps.com/start
# sso_region = us-east-1
# sso_account_id = 123456789012
# sso_role_name = MyRole
# region = us-east-1
EOF
        log_success "Created AWS config template at $aws_dir/config"
    fi

    echo ""
    echo "AWS CLI configuration:"
    echo "  1. Configure profiles: aws configure"
    echo "  2. For SSO: aws configure sso"
    echo "  3. Login: aws sso login --profile <profile>"
    echo ""
}

configure_infisical() {
    echo ""
    echo "Infisical configuration:"
    echo "  1. Login: infisical login"
    echo "  2. Init project: infisical init"
    echo "  3. Run with secrets: infisical run -- <command>"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

show_usage() {
    cat <<EOF
Usage: $0 [COMMAND]

Install and configure secrets management tools

Commands:
    all         Install all tools (default)
    1password   Install 1Password CLI
    aws         Install AWS CLI
    infisical   Install Infisical CLI
    tailscale   Install Tailscale
    configure   Show configuration instructions
    status      Show installation status
    help        Show this help message

EOF
}

show_status() {
    echo "Secrets Management Tools Status:"
    echo ""
    printf "  %-15s %s\n" "1Password CLI:" "$(command -v op &>/dev/null && op --version || echo 'not installed')"
    printf "  %-15s %s\n" "AWS CLI:" "$(command -v aws &>/dev/null && aws --version 2>&1 | cut -d' ' -f1 || echo 'not installed')"
    printf "  %-15s %s\n" "Infisical:" "$(command -v infisical &>/dev/null && infisical --version 2>&1 || echo 'not installed')"
    printf "  %-15s %s\n" "Tailscale:" "$(command -v tailscale &>/dev/null && tailscale version 2>&1 | head -1 || echo 'not installed')"
    echo ""
}

main() {
    case "${1:-all}" in
        all)
            install_1password
            install_aws
            install_infisical
            install_tailscale
            echo ""
            log_success "All tools installed"
            show_status
            ;;
        1password|op)
            install_1password
            configure_1password
            ;;
        aws)
            install_aws
            configure_aws
            ;;
        infisical|inf)
            install_infisical
            configure_infisical
            ;;
        tailscale|ts)
            install_tailscale
            ;;
        configure|config)
            configure_1password
            configure_aws
            configure_infisical
            ;;
        status)
            show_status
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
