#!/bin/bash
# One-command setup for new machines
set -e

echo "🚀 Quick setup for DROO's dotfiles..."

# Detect NixOS
is_nixos() {
    [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release
}

# Install chezmoi if not present
if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install chezmoi
    elif is_nixos; then
        echo "Detected NixOS - installing chezmoi via nix-env..."
        nix-env -iA nixos.chezmoi 2>/dev/null || nix-env -iA nixpkgs.chezmoi 2>/dev/null || nix-env -i chezmoi 2>/dev/null || echo "Failed to install chezmoi via nix-env"
    else
        sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$USER"
    fi
fi

# Initialize and apply dotfiles
chezmoi init --apply https://github.com/hydepwns/dotfiles.git

echo "✅ Setup complete! Restart your terminal."
