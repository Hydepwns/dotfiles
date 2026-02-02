# DROO's Dotfiles

[![Plugins](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugins?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/Hydepwns/dotfiles)

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io) - featuring modular zsh, unified Synthwave84 theming, secrets management, and Tailscale integration.

## Quick Start

```bash
# Full bootstrap (installs everything)
curl -fsSL https://raw.githubusercontent.com/Hydepwns/dotfiles/main/scripts/install/remote-bootstrap.sh | bash

# Minimal install
brew install chezmoi && chezmoi init --apply https://github.com/Hydepwns/dotfiles.git

# NixOS
curl -fsSL https://raw.githubusercontent.com/Hydepwns/dotfiles/main/scripts/setup/nixos-setup.sh | bash
```

## Core Commands

| Command | Description |
|---------|-------------|
| `make install` | Install dotfiles |
| `make update` | Update from remote |
| `make doctor` | Health check |
| `make dashboard` | Service status dashboard |
| `make sync` | Sync local changes |

## Tools

| Category | Tools |
|----------|-------|
| **Terminal** | Ghostty (macOS), Kitty (Linux) |
| **Editor** | Zed, Neovim |
| **Shell** | Zsh + Starship prompt |
| **Secrets** | 1Password, AWS CLI, Infisical |
| **Network** | Tailscale |
| **Languages** | Node.js, Rust, Python, Elixir, Go, Lua |
| **Version Mgmt** | asdf, direnv, devenv, Nix |

## Features

### Secrets Management

```bash
make setup-secrets    # Install 1Password, AWS CLI, Infisical, Tailscale
make dashboard        # Check auth status for all services
```

| Provider | Purpose | Commands |
|----------|---------|----------|
| **1Password** | Primary secrets, SSH agent | `opl`, `opw`, `op-secret` |
| **AWS CLI** | Cloud credentials | `awsw`, `aws-profile`, `aws-login` |
| **Infisical** | Backup secrets | `infl`, `inf-env` |

### SSH & Tailscale

```bash
make rotate-keys      # Generate new SSH key, store in 1Password, sync to hosts
make sync-keys        # Sync public key to all Tailscale nodes
make keys-status      # Show rotation status
```

Pre-configured Tailscale hosts: bazzite, dappnode-droo, dravado, mini-axol, ovh-solver, ovh-ubuntu1, slcl03-blackknight, turing-node-1/2/3, udm-pro

### Unified Theming

Single source of truth for Synthwave84 theme across all tools.

```bash
make theme-generate   # Generate configs for Ghostty, Kitty, Alacritty
```

Theme source: `config/theme/synthwave84.toml`

### Starship Prompt

Fast, minimal prompt with git status and language versions.

```bash
make setup-starship   # Install and configure
```

### XDG Compliance

Configs organized under `~/.config/`, data under `~/.local/share/`, cache under `~/.cache/`.

### Performance

95% faster shell startup via lazy loading.

```bash
make perf             # Benchmark startup
make perf-report      # Generate report
```

## Project Templates

```bash
make generate-template TEMPLATE=web3 NAME=my-project
make generate-template TEMPLATE=nextjs NAME=my-app
make generate-template TEMPLATE=rust NAME=my-cli
```

Available: web3, nextjs, rust, elixir, node, python, go

## Configuration

Edit `chezmoi.toml` to enable/disable features:

```toml
[data]
ohmyzsh = true
starship = true
tailscale = true
onepassword = true
aws = true
nodejs = true
nix = true
```

## Directory Structure

```
dotfiles/
├── home/              # Chezmoi source -> ~/
│   ├── dot_zsh/       # Modular zsh config
│   └── dot_ssh/       # SSH config with Tailscale hosts
├── config/            # App configs (ghostty, kitty, nvim, zed, starship)
│   └── theme/         # Unified Synthwave84 theme
└── scripts/
    ├── setup/         # Installation scripts
    └── utils/         # Maintenance utilities
```

## Documentation

- [Advanced Usage](docs/advanced-usage.md)
- [Neovim Plugins](docs/nvim-plugins.md) (56 plugins)
- [Templates](docs/templates.md)
- [Performance](docs/performance.md)
- [NixOS Installation](docs/nixos-installation.md)

## Related

- [nix-mox](https://github.com/Hydepwns/nix-mox) - Nix Home Manager configuration
- [synthwave84-zed](https://github.com/Hydepwns/synthwave84-zed) - Synthwave84 theme for Zed

---

[chezmoi]: https://chezmoi.io
