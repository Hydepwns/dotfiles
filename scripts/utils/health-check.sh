#!/bin/bash

# Health check script for dotfiles
# This script verifies that all components are properly installed and configured

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/colors.sh"

log_info "Running dotfiles health check..."
print_section "Health Check"

# Check chezmoi installation
print_subsection "Chezmoi"
if command -v chezmoi &> /dev/null; then
    print_status "OK" "chezmoi is installed ($(chezmoi --version))"
else
    print_status "ERROR" "chezmoi is not installed"
fi

# Check git configuration
print_subsection "Git Configuration"
if git config --global --get user.name &> /dev/null; then
    print_status "OK" "Git user.name is set: $(git config --global --get user.name)"
else
    print_status "WARN" "Git user.name is not set"
fi

if git config --global --get user.email &> /dev/null; then
    print_status "OK" "Git user.email is set: $(git config --global --get user.email)"
else
    print_status "WARN" "Git user.email is not set"
fi

# Check shell configuration
print_subsection "Shell Configuration"
print_status "INFO" "Current shell: $SHELL"

if command -v zsh &> /dev/null; then
    print_status "OK" "Zsh is installed ($(zsh --version | head -n1))"
else
    print_status "WARN" "Zsh is not installed"
fi

# Check if zsh is the default shell
if [[ "$SHELL" == *"zsh"* ]]; then
    print_status "OK" "Zsh is the default shell"
else
    print_status "WARN" "Zsh is not the default shell (current: $SHELL)"
fi

# Check development tools
print_subsection "Development Tools"

# Check Homebrew (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
        print_status "OK" "Homebrew is installed"
    else
        print_status "WARN" "Homebrew is not installed"
    fi
fi

# Check Node.js
if command -v node &> /dev/null; then
    print_status "OK" "Node.js is installed ($(node --version))"
else
    print_status "WARN" "Node.js is not installed"
fi

# Check Rust
if command -v rustc &> /dev/null; then
    print_status "OK" "Rust is installed ($(rustc --version))"
else
    print_status "WARN" "Rust is not installed"
fi

# Check Python
if command -v python3 &> /dev/null; then
    print_status "OK" "Python 3 is installed ($(python3 --version))"
else
    print_status "WARN" "Python 3 is not installed"
fi

# Check Python version from .tool-versions
if [[ -f .tool-versions ]] && grep -q "^python " .tool-versions; then
    expected_version=$(grep "^python " .tool-versions | cut -d' ' -f2)
    print_status "INFO" "Expected Python version: $expected_version"
fi

# Check asdf
if command -v asdf &> /dev/null; then
    print_status "OK" "asdf is installed"
else
    print_status "INFO" "asdf is not installed"
fi

# Check NVM
if command -v nvm &> /dev/null; then
    print_status "OK" "NVM is installed"
elif [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    print_status "OK" "NVM is installed but not loaded"
else
    print_status "INFO" "NVM is not installed"
fi

# Check rbenv
if command -v rbenv &> /dev/null; then
    print_status "OK" "rbenv is installed"
else
    print_status "INFO" "rbenv is not installed"
fi

# Check Elixir
if command -v elixir &> /dev/null; then
    print_status "OK" "Elixir is installed ($(elixir --version | head -n1))"
else
    print_status "INFO" "Elixir is not installed"
fi

# Check Lua
if command -v lua &> /dev/null; then
    print_status "OK" "Lua is installed ($(lua -v))"
else
    print_status "INFO" "Lua is not installed"
fi

# Check direnv
if command -v direnv &> /dev/null; then
    print_status "OK" "direnv is installed"
else
    print_status "INFO" "direnv is not installed"
fi

# Check Nix
if command -v nix &> /dev/null; then
    print_status "OK" "Nix is installed"
else
    print_status "INFO" "Nix is not installed"
fi

# Check Neovim
if command -v nvim &> /dev/null; then
    print_status "OK" "Neovim is installed ($(nvim --version | head -n1))"
else
    print_status "INFO" "Neovim is not installed"
fi

# Check chezmoi data
print_subsection "Chezmoi Configuration"
if [[ -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
    print_status "OK" "chezmoi configuration exists"
else
    print_status "WARN" "chezmoi configuration not found"
fi

# Check if dotfiles are applied
if chezmoi status &> /dev/null; then
    print_status "OK" "Dotfiles are properly applied"
else
    print_status "WARN" "Dotfiles may not be properly applied"
fi

# Check SSH and GitHub configuration
print_subsection "SSH and GitHub"
check_ssh_keys() {
    # Check for various SSH key types
    local ssh_keys=()
    [[ -f ~/.ssh/id_rsa ]] && ssh_keys+=("id_rsa")
    [[ -f ~/.ssh/id_ed25519 ]] && ssh_keys+=("id_ed25519")
    [[ -f ~/.ssh/id_ecdsa ]] && ssh_keys+=("id_ecdsa")
    [[ -f ~/.ssh/id_dsa ]] && ssh_keys+=("id_dsa")

    # Check for loaded SSH keys
    if ssh-add -l &> /dev/null && [[ $(ssh-add -l | wc -l) -gt 0 ]]; then
        local loaded_keys
        loaded_keys=$(ssh-add -l | head -1 | cut -d' ' -f3)
        print_status "OK" "SSH keys loaded: $loaded_keys"
    elif [[ ${#ssh_keys[@]} -gt 0 ]]; then
        print_status "OK" "SSH private keys found: ${ssh_keys[*]}"
    else
        print_status "WARN" "SSH private key not found"
    fi
}

check_github_token() {
    if [[ -n "$GITHUB_TOKEN" ]]; then
        print_status "OK" "GitHub token is set"
    else
        print_status "WARN" "GitHub token not found"
    fi
}

check_ssh_keys
check_github_token

log_success "Health check complete!"
