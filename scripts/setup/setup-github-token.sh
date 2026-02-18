#!/usr/bin/env bash
# Setup GitHub Personal Access Token for chezmoi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/simple-init.sh
source "$SCRIPT_DIR/../utils/simple-init.sh"

show_usage() {
    cat <<EOF
Usage: $0

Interactive setup for GitHub Personal Access Token.

This token allows chezmoi to fetch SSH public keys from GitHub.
The token will be saved to your shell profile (~/.zshrc or ~/.bash_profile).

Required GitHub token scope: read:user
EOF
}

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "help" ]]; then
    show_usage
    exit 0
fi

echo " Setting up GitHub Personal Access Token for chezmoi"
echo "=================================================="
echo ""
echo "This script will help you set up a GitHub token so chezmoi can fetch your SSH keys."
echo ""

# Check if token is already set
if [ -n "$GITHUB_TOKEN" ] && [ "$GITHUB_TOKEN" != "your_personal_access_token" ]; then
    echo " GitHub token is already set: ${GITHUB_TOKEN:0:10}..."
    echo ""
else
    echo "Please follow these steps:"
    echo ""
    echo "1. Go to: https://github.com/settings/tokens"
    echo "2. Click 'Generate new token (classic)'"
    echo "3. Give it a name like 'chezmoi-ssh-keys'"
    echo "4. Select the 'read:user' scope (to read public keys)"
    echo "5. Click 'Generate token'"
    echo "6. Copy the generated token"
    echo ""

    read -r -p "Enter your GitHub Personal Access Token: " token

    if [ -n "$token" ]; then
        # Add to current session
        export GITHUB_TOKEN="$token"

        # Add to shell profile
        if [[ "$SHELL" == *"zsh"* ]]; then
            profile="$HOME/.zshrc"
        else
            profile="$HOME/.bash_profile"
        fi

        {
            echo ""
            echo "# GitHub token for chezmoi SSH key fetching"
            echo "export GITHUB_TOKEN=\"$token\""
        } >> "$profile"

        echo " Token added to $profile"
        echo " Please restart your terminal or run: source $profile"
        echo ""
    else
        echo " No token provided. Please run this script again."
        exit $EXIT_FAILURE
    fi
fi

# Load constants for identity
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../utils/constants.sh
source "$DOTFILES_ROOT/scripts/utils/constants.sh"

echo " Testing GitHub API access..."
if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -q "${GITHUB_USER:-hydepwns}"; then
    echo " GitHub API access working!"
    echo ""
    echo " Now you can run: chezmoi apply"
else
    echo " GitHub API access failed. Please check your token."
    exit $EXIT_FAILURE
fi
