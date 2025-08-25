# NixOS Installation Guide

## Overview

This guide explains how to install DROO's dotfiles on NixOS systems and why special handling is required.

## Why NixOS Needs Special Handling

NixOS has a unique package management system that doesn't allow running dynamically linked executables from generic Linux distributions. When the standard installation script tries to download and run the chezmoi binary, it fails with:

```bash
Could not start dynamically linked executable: bin/chezmoi
NixOS cannot run dynamically linked executables intended for generic
linux environments out of the box.
```

## Installation Methods

### Method 1: NixOS-Specific Script (Recommended)

```bash
bash scripts/setup/nixos-quick-fix.sh
```

This script:

- Detects NixOS automatically
- Installs chezmoi via `nix-env -iA nixpkgs.chezmoi`
- Installs required dependencies (git, zsh, curl) via nix-env
- Initializes and applies the dotfiles
- Sets zsh as the default shell

### Method 2: Updated Quick Setup Script

```bash
curl -fsSL https://raw.githubusercontent.com/hydepwns/dotfiles/main/scripts/setup/quick-setup.sh | bash
```

The quick setup script now automatically detects NixOS and uses the appropriate installation method.

### Method 3: Manual Installation

If you prefer to install manually:

```bash
# Install chezmoi via nix-env
nix-env -iA nixpkgs.chezmoi

# Install dependencies
nix-env -iA nixpkgs.git nixpkgs.zsh nixpkgs.curl

# Initialize and apply dotfiles
chezmoi init --apply https://github.com/hydepwns/dotfiles.git
```

## What's Different on NixOS

1. **Package Installation**: Uses `nix-env` instead of downloading binaries
2. **Dependency Management**: All tools are installed through the Nix package manager
3. **Shell Configuration**: The dotfiles include Nix-specific configuration in `.zshrc`

## Post-Installation

After installation:

1. Restart your terminal or run `exec zsh`
2. Run `make doctor` to verify the installation
3. Customize your configuration as needed

## Troubleshooting

### Issue: "nix-env command not found"

If `nix-env` is not available, you may need to enable it in your NixOS configuration:

```nix
# In /etc/nixos/configuration.nix
environment.systemPackages = with pkgs; [
  nix-env
  # ... other packages
];
```

### Issue: Permission denied when setting shell

You may need to add zsh to the allowed shells:

```nix
# In /etc/nixos/configuration.nix
users.defaultUserShell = pkgs.zsh;
```

## Nix Integration

The dotfiles include Nix integration features:

- Automatic sourcing of Nix profile scripts
- Support for devenv projects
- Nix-specific tool configurations

These features are automatically enabled when `nix = true` is set in the chezmoi configuration.
