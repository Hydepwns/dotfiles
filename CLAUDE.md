# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chezmoi-based cross-platform dotfiles with modular zsh configuration. Primary platform is macOS (Apple Silicon), with Linux/NixOS support. Uses template-driven configuration with 30+ conditional features and achieves 95% shell startup speedup via lazy-loading.

## Key Commands

```bash
# Core chezmoi operations
make install              # Fresh install: chezmoi init --apply
make update               # Pull and apply remote changes
make diff                 # Preview pending changes
make status               # Show dotfile status
chezmoi apply             # Apply local changes to home directory

# Development
make test                 # Run test suite (zsh syntax, module loading, security)
make doctor               # Health check all configs and tools
make perf                 # Benchmark shell startup time
make perf-report          # Generate performance report

# Maintenance
make backup               # Backup current dotfiles
make sync                 # Push local changes to git
make clean                # Remove temp files

# Setup tools
make setup-secrets        # Install 1Password CLI, AWS CLI, Infisical, Tailscale
make setup-tailscale      # Install Tailscale only
make setup-ci             # Install pre-commit hooks

# Dashboard and monitoring
make dashboard            # Show comprehensive service status
make dashboard-watch      # Auto-refreshing dashboard
make dashboard-secrets    # Secrets providers status only

# SSH key rotation
make rotate-keys          # Generate new key, store in 1Password, sync to hosts
make sync-keys            # Sync public key to all Tailscale hosts
make keys-status          # Show SSH key rotation status

# Utilities
./scripts/utils/config-manager.sh list      # Show all config file statuses
./scripts/utils/health-check.sh             # Detailed system health
./scripts/utils/lazy-load-tools.sh stats    # Lazy loading performance stats
```

## Bootstrap (Fresh Machine)

One-liner for new machines:
```bash
curl -fsSL https://raw.githubusercontent.com/Hydepwns/dotfiles/main/scripts/install/remote-bootstrap.sh | bash
```

This installs: Homebrew, chezmoi, git, zsh, 1Password CLI, AWS CLI, Infisical, Tailscale, and applies all dotfiles.

## Architecture

### Chezmoi Template System

Configuration in `chezmoi.toml` drives conditional features:
```toml
[data]
nodejs = true      # Enables Node.js PATH and asdf config
tailscale = true   # Enables Tailscale aliases and SSH hosts
onepassword = true # Enables 1Password SSH agent
```

Template files (`.tmpl`) use Go template syntax:
```bash
{{- if .nodejs -}}
export PATH="$HOME/.asdf/installs/nodejs/18.19.0/bin:$PATH"
{{- end -}}
```

### Directory Mapping

| Source | Destination | Purpose |
|--------|-------------|---------|
| `home/dot_*` | `~/.*` | Chezmoi-managed dotfiles |
| `home/dot_zsh/` | `~/.zsh/` | Modular zsh configuration |
| `home/dot_claude/` | `~/.claude/` | Claude Code config (CLAUDE.md, settings.json) |
| `home/private_dot_config/ghostty/` | `~/.config/ghostty/` | Ghostty terminal config |
| `home/private_dot_config/zed/` | `~/.config/zed/` | Zed editor settings |
| `config/` | Manual deploy | Theme source, starship, extra configs |
| `scripts/setup/` | - | One-time installation scripts |
| `scripts/utils/` | - | Ongoing maintenance utilities |

### Modular Zsh Architecture

Entry point: `home/dot_zshrc` sources `~/.zsh/modules.zsh`

```
home/dot_zsh/
├── modules.zsh           # Loader: sources all subdirectory .zsh files
├── core/
│   ├── lazy-loading.zsh  # Deferred init for nvm, asdf, direnv, devenv
│   ├── secrets.zsh       # 1Password, AWS, Infisical integration
│   ├── ssh.zsh           # SSH agent and key management
│   ├── paths.zsh         # Centralized PATH registry
│   └── platforms/        # macos.zsh, linux.zsh
├── aliases/
│   └── dev.zsh           # All shell aliases
└── functions/            # Shell functions
```

### Lazy Loading Pattern

Tools load only on first use to optimize startup:
```bash
# In lazy-loading.zsh
lazy_load_nvm() {
    unfunction nvm node npm npx 2>/dev/null
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
}
nvm() { lazy_load_nvm && nvm "$@" }
```

### Secrets Management

Three-tier approach in `core/secrets.zsh`:
1. **1Password** (primary) - SSH agent enabled on macOS via `SSH_AUTH_SOCK`
2. **AWS CLI** - SSO profile switching with `aws-profile <name>`
3. **Infisical** (backup) - `inf-env <environment>` loads secrets

Unified API: `get-secret <name>` tries 1Password first, falls back to Infisical.

## Adding New Features

### New shell aliases/functions
Add to `home/dot_zsh/aliases/dev.zsh` or create new file in `aliases/` or `functions/`

### New conditional tool support
1. Add variable to `chezmoi.toml`: `mytool = true`
2. Use in templates: `{{- if .mytool -}}...{{- end -}}`

### New setup script
Create `scripts/setup/setup-mytool.sh`, add Makefile target:
```makefile
setup-mytool: ## Install mytool
	@$(SCRIPTS_DIR)/setup/setup-mytool.sh
```

### New application config
Add to `config/myapp/`, document deployment in README or create symlink script

## Code Style

- Shell scripts: bash with `set -e`, shellcheck compliant
- Zsh configs: Source shared utilities from `scripts/utils/{colors,helpers,constants}.sh`
- Chezmoi templates: Use `{{- -}}` to trim whitespace
- Prefer functional patterns, avoid imperative loops where map/filter suffices

## SSH and Tailscale

SSH config (`home/dot_ssh/config.tmpl`) includes:
- 1Password SSH agent integration on macOS
- All Tailscale hosts with MagicDNS names
- `AddKeysToAgent yes` and `UseKeychain yes` for automatic key loading

Tailscale hosts are pre-configured: bazzite, dappnode-droo, dravado, mini-axol, ovh-solver, ovh-ubuntu1, slcl03-blackknight, turing-node-1/2/3, udm-pro

## Unified Theming

Single source of truth: `config/theme/synthwave84.toml`

```bash
make theme-generate    # Generate configs for all tools
```

Generates: Ghostty, Kitty, Alacritty, CSS variables, shell color exports.

## XDG Compliance

XDG paths defined in `home/dot_zsh/core/xdg.zsh`:
- `$XDG_CONFIG_HOME` (~/.config) - configs
- `$XDG_DATA_HOME` (~/.local/share) - data
- `$XDG_STATE_HOME` (~/.local/state) - history
- `$XDG_CACHE_HOME` (~/.cache) - cache

Tool overrides: npm, cargo, go, python, docker, aws, k8s, starship, asdf.

## Prompt

Starship prompt configured in `config/starship/starship.toml` with Synthwave84 colors. Falls back to simple git-aware prompt if Starship not installed.

## Claude Code Config

Global preferences in `home/dot_claude/`:
- `CLAUDE.md` - Coding style preferences (no emojis, functional patterns, etc.)
- `settings.json` - Plugin settings, thinking mode

Runtime files (history, cache, telemetry) are ignored via `.chezmoiignore`.

## Brewfile (macOS)

Declarative package management via `Brewfile` at repo root.

```bash
make brew-install   # Install all packages
make brew-dump      # Update Brewfile from current system
make brew-check     # Check for drift
make brew-cleanup   # Remove unlisted packages
make brew-update    # Update Homebrew and packages
```
