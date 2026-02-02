# shellcheck disable=all
# Secrets management - 1Password, AWS, Infisical

# =============================================================================
# 1Password CLI Integration
# =============================================================================

# Enable 1Password SSH agent (macOS)
if [[ "$(uname -s)" == "Darwin" ]]; then
    export SSH_AUTH_SOCK="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# Get secret from 1Password
op-secret() {
    local item="$1"
    local field="${2:-password}"
    op item get "$item" --fields "$field" 2>/dev/null
}

# Inject 1Password secrets into environment
op-env() {
    if ! op whoami &>/dev/null; then
        echo "Not signed in to 1Password. Run: op signin"
        return 1
    fi
    echo "1Password session active"
}

# =============================================================================
# AWS CLI Integration
# =============================================================================

# AWS profile switcher
aws-profile() {
    local profile="$1"
    if [[ -z "$profile" ]]; then
        echo "Current: ${AWS_PROFILE:-default}"
        echo "Available profiles:"
        aws configure list-profiles 2>/dev/null | sed 's/^/  /'
        return 0
    fi
    export AWS_PROFILE="$profile"
    echo "Switched to AWS profile: $profile"
}

# AWS SSO login helper
aws-login() {
    local profile="${1:-$AWS_PROFILE}"
    if [[ -z "$profile" ]]; then
        echo "Usage: aws-login <profile>"
        return 1
    fi
    aws sso login --profile "$profile"
}

# Get current AWS identity
aws-whoami() {
    aws sts get-caller-identity --output table 2>/dev/null || echo "Not authenticated"
}

# =============================================================================
# Infisical (Backup Secrets Provider)
# =============================================================================

# Infisical environment loader
inf-env() {
    local env="${1:-dev}"
    if ! infisical login --check &>/dev/null; then
        echo "Not logged in to Infisical. Run: infisical login"
        return 1
    fi
    eval "$(infisical export --env="$env" 2>/dev/null)"
    echo "Loaded Infisical secrets for: $env"
}

# Run command with Infisical secrets
inf-run() {
    local env="${1:-dev}"
    shift
    infisical run --env="$env" -- "$@"
}

# =============================================================================
# Unified Secrets Helper
# =============================================================================

# Get secret from preferred provider (1Password first, Infisical fallback)
get-secret() {
    local name="$1"
    local result

    # Try 1Password first
    if command -v op &>/dev/null && op whoami &>/dev/null 2>&1; then
        result=$(op item get "$name" --fields password 2>/dev/null)
        if [[ -n "$result" ]]; then
            echo "$result"
            return 0
        fi
    fi

    # Fallback to Infisical
    if command -v infisical &>/dev/null; then
        result=$(infisical secrets get "$name" --plain 2>/dev/null)
        if [[ -n "$result" ]]; then
            echo "$result"
            return 0
        fi
    fi

    echo "Secret not found: $name" >&2
    return 1
}
