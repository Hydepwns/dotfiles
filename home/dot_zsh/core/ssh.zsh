# shellcheck disable=all
# SSH agent and key management

# Start SSH agent if not running (Linux)
# macOS handles this automatically via launchd
if [[ "$(uname -s)" == "Linux" ]]; then
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
        eval "$(ssh-agent -s)" > /dev/null 2>&1
    fi
fi

# macOS: Handle 1Password SSH agent conflict with Keychain-stored keys
# 1Password sets SSH_AUTH_SOCK to its agent, but Keychain keys need macOS native agent
if [[ "$(uname -s)" == "Darwin" ]]; then
    # Detect if 1Password agent is active (contains "1password" in path)
    if [[ "$SSH_AUTH_SOCK" == *"1password"* || "$SSH_AUTH_SOCK" == *"2BUA8C4S2C"* ]]; then
        # Find macOS launchd SSH agent socket
        _macos_agent=$(find /private/tmp -name "Listeners" -path "*/com.apple.launchd.*" 2>/dev/null | head -1)
        if [[ -S "$_macos_agent" ]]; then
            # Export for subprocesses (Ansible, git, etc.)
            export SSH_AUTH_SOCK_MACOS="$_macos_agent"
            # Override to use macOS agent for Keychain-stored keys
            export SSH_AUTH_SOCK="$_macos_agent"
        fi
        unset _macos_agent
    fi
fi

# Function to add SSH keys to agent
ssh-add-keys() {
    local key_dir="${HOME}/.ssh"
    local keys_added=0

    # Check if agent is running
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
        echo "SSH agent not running"
        return 1
    fi

    # Add default key
    if [[ -f "${key_dir}/id_ed25519" ]]; then
        if [[ "$(uname -s)" == "Darwin" ]]; then
            ssh-add --apple-use-keychain "${key_dir}/id_ed25519" 2>/dev/null && ((keys_added++))
        else
            ssh-add "${key_dir}/id_ed25519" 2>/dev/null && ((keys_added++))
        fi
    fi

    # Add id_rsa if exists
    if [[ -f "${key_dir}/id_rsa" ]]; then
        if [[ "$(uname -s)" == "Darwin" ]]; then
            ssh-add --apple-use-keychain "${key_dir}/id_rsa" 2>/dev/null && ((keys_added++))
        else
            ssh-add "${key_dir}/id_rsa" 2>/dev/null && ((keys_added++))
        fi
    fi

    echo "Added ${keys_added} key(s) to SSH agent"
}

# Function to list loaded keys
ssh-list-keys() {
    ssh-add -l 2>/dev/null || echo "No keys loaded in agent"
}

# On macOS, load keys from keychain on first use
if [[ "$(uname -s)" == "Darwin" ]]; then
    # Apple's ssh-add with --apple-load-keychain loads all keys stored in keychain
    ssh-add --apple-load-keychain 2>/dev/null
fi
