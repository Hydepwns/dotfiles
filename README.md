# DROO's Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) - featuring modular tool loading, project templates, and development automation.

[![CI](https://github.com/hydepwns/dotfiles/workflows/CI/badge.svg)](https://github.com/hydepwns/dotfiles/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![chezmoi](https://img.shields.io/badge/chezmoi-managed-blue.svg)](https://www.chezmoi.io/)
![Lazy Loading](https://img.shields.io/badge/Lazy_Loading-Enabled-green) ![Monitoring](https://img.shields.io/badge/Monitoring-Active-blue)

## 🚀 Quick Start

### Option 1: One-Command Setup (Recommended)

```bash
# Run the quick setup script
curl -fsSL https://raw.githubusercontent.com/hydepwns/dotfiles/main/scripts/setup/quick-setup.sh | bash
```

### Option 2: Manual Setup

```bash
# Install chezmoi
brew install chezmoi  # macOS
# or
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $USER  # Linux

# Initialize and apply
chezmoi init --apply https://github.com/hydepwns/dotfiles.git
```

### Option 3: Comprehensive Bootstrap

```bash
# For full system setup with dependencies
curl -fsSL https://raw.githubusercontent.com/hydepwns/dotfiles/main/scripts/setup/bootstrap.sh | bash
```

## 📋 Setup Scripts Guide

Choose the right setup script for your needs:

| Script | Purpose | Best For |
|--------|---------|----------|
| **`scripts/setup/quick-setup.sh`** | One-command setup | New machines, quick start |
| **`scripts/setup/bootstrap.sh`** | Complete bootstrap | Full system setup with dependencies |
| **`scripts/setup/setup-cursor.sh`** | Cursor IDE configuration | After initial setup, configure Cursor |
| **`scripts/setup/setup-cursor-simple.sh`** | Basic Cursor setup | Simple Cursor configuration |
| **`scripts/setup/setup-ci.sh`** | CI/CD tools setup | Development workflow setup |
| **`scripts/setup/setup-github-token.sh`** | GitHub authentication | Set up GitHub access |

## ✨ Features

> **Lazy Loading**: Version managers (NVM, rbenv, asdf, direnv) load only when used
>
> **Performance Monitoring**: Real-time tracking of shell startup and tool loading times
>
> **Smart Caching**: Tools remain available once loaded in session (~48% faster startup time)
>
> **Modular Configuration**: Modular shell configuration modules in `home/dot_zsh/core/`

### 🛠️ Core Tools & Languages

| Category | Tools |
|----------|-------|
| **Shell & Terminal** | ![Zsh](https://img.shields.io/badge/Zsh-1.2.0-000000?style=flat&logo=gnu-bash&logoColor=white) ![Kitty](https://img.shields.io/badge/Kitty-0.30.1-000000?style=flat&logo=kitty&logoColor=white) |
| **Version Control** | ![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white) |
| **Editors** | ![Neovim](https://img.shields.io/badge/Neovim-57C3C2?style=flat&logo=neovim&logoColor=white) ![Zed](https://img.shields.io/badge/Zed-000000?style=flat&logo=zed&logoColor=white) ![Cursor](https://img.shields.io/badge/Cursor-000000?style=flat&logo=cursor&logoColor=white) |
| **Package Managers** | ![Homebrew](https://img.shields.io/badge/Homebrew-FBB040?style=flat&logo=homebrew&logoColor=black) ![pnpm](https://img.shields.io/badge/pnpm-F69220?style=flat&logo=pnpm&logoColor=white) ![pipx](https://img.shields.io/badge/pipx-000000?style=flat&logo=python&logoColor=white) |
| **Languages** | ![Rust](https://img.shields.io/badge/Rust-000000?style=flat&logo=rust&logoColor=white) ![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white) ![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white) ![Elixir](https://img.shields.io/badge/Elixir-4B275F?style=flat&logo=elixir&logoColor=white) ![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat&logo=lua&logoColor=white) ![Go](https://img.shields.io/badge/Go-00ADD8?style=flat&logo=go&logoColor=white) |
| **Web3 & Frameworks** | ![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=flat&logo=ethereum&logoColor=white) ![Foundry](https://img.shields.io/badge/Foundry-000000?style=flat&logo=foundry&logoColor=white) ![Solana](https://img.shields.io/badge/Solana-14F46D?style=flat&logo=solana&logoColor=white) ![Next.js](https://img.shields.io/badge/Next.js-000000?style=flat&logo=nextdotjs&logoColor=white) |

### 🚀 Project Templates

- **Web3**: ![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=flat&logo=ethereum&logoColor=white)/![Foundry](https://img.shields.io/badge/Foundry-000000?style=flat&logo=foundry&logoColor=white) and ![Solana](https://img.shields.io/badge/Solana-14F46D?style=flat&logo=solana&logoColor=white)/![Anchor](https://img.shields.io/badge/Anchor-000000?style=flat&logo=anchor&logoColor=white) development
- **Next.js**: ![Next.js](https://img.shields.io/badge/Next.js-000000?style=flat&logo=nextdotjs&logoColor=white) TypeScript, Tailwind, testing setup
- **Rust**: ![Rust](https://img.shields.io/badge/Rust-000000?style=flat&logo=rust&logoColor=white) Common dependencies and web framework options

## ⚙️ Configuration

### Initial Setup Process

The setup prompts for your preferences:

- Email and username
- Which tools you use (Nix, Oh My Zsh, asdf, etc.)
- Work vs personal machine: personal machine will have SSH keys and GitHub token

### SSH Setup (Optional)

```bash
# 1. Create GitHub token with 'read:user' scope
export GITHUB_TOKEN="your_token_here"

# 2. Apply configuration
chezmoi apply
```

### Performance Monitoring

```bash
# Measure current performance
make performance-monitor ACTION=measure

# Analyze performance data
make performance-monitor ACTION=analyze

# View performance history
make performance-monitor ACTION=history
```

## 🎨 Editor Configurations

### Core Editors

![Neovim](https://img.shields.io/badge/Neovim-57C3C2?style=flat&logo=neovim&logoColor=white) ![Zed](https://img.shields.io/badge/Zed-000000?style=flat&logo=zed&logoColor=white) ![Cursor](https://img.shields.io/badge/Cursor-000000?style=flat&logo=cursor&logoColor=white) ![Kitty](https://img.shields.io/badge/Kitty-0.30.1-000000?style=flat&logo=kitty&logoColor=white)

**Features**: LazyNvim, SynthWave themes, Monaspace fonts, AI-powered development, comprehensive plugin suites

## 🏗️ Architecture

### Modular Shell Configuration

![Zsh](https://img.shields.io/badge/Zsh-Modular-000000?style=flat&logo=gnu-bash&logoColor=white) ![Cross-Platform](https://img.shields.io/badge/Cross--Platform-Compatible-blue) ![Performance](https://img.shields.io/badge/Performance-Optimized-green)

**Core modules**: paths, platforms, tools, config, lazy-loading
**Principles**: DRY, centralized PATH management, cross-platform compatibility, performance-first

### Centralized PATH Management

All tool paths managed through `home/dot_zsh/core/paths.zsh`:

![Version Managers](https://img.shields.io/badge/Version_Managers-rbenv,nvm,asdf,erlang,elixir,lua-orange) ![Dev Tools](https://img.shields.io/badge/Dev_Tools-LLVM,PostgreSQL,Python-blue) ![Web3](https://img.shields.io/badge/Web3-Foundry,Huff,Solana-purple) ![Package Managers](https://img.shields.io/badge/Package_Managers-Homebrew,pnpm,pipx-green) ![Nix](https://img.shields.io/badge/Nix-Paths-red)

## 🛠️ Usage

### Basic Commands

```bash
# Install dotfiles
make install

# Update from remote
make update

# Show differences
make diff

# Health check
make doctor

# Sync local changes
make sync
```

### Template Examples

```bash
# Generate Web3 project
make generate-template web3 my-defi-project ethereum solana

# Generate Next.js project
make generate-template nextjs my-webapp typescript tailwind jest

# Generate Rust project
make generate-template rust my-cli-tool
```

### Optional Tools

```bash
# Install optional tools interactively
make install-optional

# Update tool versions
make tool-versions COMMAND=update

# Setup Cursor configuration
./scripts/setup/setup-cursor-simple.sh
```

## 🔧 Available Commands

Run `make help` to see all available commands:

### Command Categories

![Core](https://img.shields.io/badge/Core-Operations-blue) ![Backup](https://img.shields.io/badge/Backup-Operations-orange) ![Health](https://img.shields.io/badge/Health-Maintenance-green) ![Sync](https://img.shields.io/badge/Sync-Operations-purple) ![Optional](https://img.shields.io/badge/Optional-Commands-gray) ![Testing](https://img.shields.io/badge/Testing-Development-red)

**Core**: `install`, `update`, `diff`, `status`
**Backup**: `backup`, `backup-full`, `clean`
**Health**: `doctor`, `bootstrap`
**Sync**: `sync`, `sync-from-remote`
**Optional**: `install-optional`
**Testing**: `performance-test`, `performance-monitor`, `generate-template`, `tool-versions`, `setup-ci`

## 🚨 Troubleshooting

- **Template errors**: Check chezmoi syntax with `{{-` and `-}}`
- **Path issues**: Verify Homebrew prefix for your architecture
- **Tool not found**: Install tool before applying configuration
- **Project templates**: Use `make generate-template` for help
- **Shell issues**: Check modular configuration in `home/dot_zsh/core/`
- **PATH problems**: All PATH management is centralized in `home/dot_zsh/core/paths.zsh`
- **Cursor setup**: Use `./scripts/setup/setup-cursor-simple.sh` for reliable configuration
- **Configuration conflicts**: Ensure only one `.chezmoi.toml` exists in repository root
- **Performance issues**: Use `make performance-monitor` to identify slow-loading tools
- **Lazy loading problems**: Check `home/dot_zsh/core/lazy-loading.zsh` for tool aliases

## 📄 License

MIT License - see LICENSE file for details.
