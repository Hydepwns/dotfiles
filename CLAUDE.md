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

# Setup tools
make setup-secrets        # Install 1Password CLI, AWS CLI, Infisical, Tailscale
make brew-install         # Install all Brewfile packages

# Dashboard and monitoring
make dashboard            # Show comprehensive service status
make dashboard-watch      # Auto-refreshing dashboard

# SSH key rotation
make rotate-keys          # Generate new key, store in 1Password, sync to hosts
make sync-keys            # Sync public key to all Tailscale hosts
```

## Bootstrap (Fresh Machine)

```bash
curl -fsSL https://raw.githubusercontent.com/Hydepwns/dotfiles/main/scripts/install/remote-bootstrap.sh | bash
```

## Architecture

### Directory Mapping

| Source | Destination | Purpose |
|--------|-------------|---------|
| `home/dot_*` | `~/.*` | Chezmoi-managed dotfiles |
| `home/dot_zsh/` | `~/.zsh/` | Modular zsh configuration |
| `home/dot_claude/` | `~/.claude/` | Claude Code config |
| `home/dot_hammerspoon/` | `~/.hammerspoon/` | macOS window management |
| `home/private_dot_config/ghostty/` | `~/.config/ghostty/` | Ghostty terminal |
| `home/private_dot_config/zed/` | `~/.config/zed/` | Zed editor |
| `home/private_dot_config/nvim/` | `~/.config/nvim/` | Neovim (lean config) |
| `config/` | Manual deploy | Theme source, starship |
| `scripts/setup/` | - | Installation scripts |
| `scripts/utils/` | - | Maintenance utilities |

### Modular Zsh Architecture

```
home/dot_zsh/
├── modules.zsh           # Loader
├── core/
│   ├── lazy-loading.zsh  # Deferred init for nvm, asdf, direnv
│   ├── secrets.zsh       # 1Password, AWS, Infisical
│   ├── ssh.zsh           # SSH agent management
│   ├── tools.zsh         # fzf, zoxide, eza, bat integration
│   ├── xdg.zsh           # XDG compliance
│   ├── prompt.zsh        # Starship initialization
│   └── platforms/        # macos.zsh, linux.zsh
├── aliases/
│   └── dev.zsh           # All shell aliases
└── functions/            # Shell functions
```

### Terminal Power Tools

Configured in `core/tools.zsh` with Synthwave84 theme colors:

| Tool | Alias | Usage |
|------|-------|-------|
| fzf | - | `Ctrl+R` history, `Ctrl+T` files, `Alt+C` cd |
| zoxide | `z` | Smart cd (`z proj` jumps to project) |
| eza | `ls`, `ll`, `la`, `lt` | Better ls with icons/git |
| bat | `cat` | Syntax highlighted cat |
| fd | `find` | Faster find |
| ripgrep | `grep`, `rg` | Faster grep |

### Secrets Management

Three-tier approach in `core/secrets.zsh`:
1. **1Password** (primary) - SSH agent via `SSH_AUTH_SOCK`
2. **AWS CLI** - SSO with `aws-profile <name>`
3. **Infisical** (backup) - `inf-env <environment>`

### Age Encryption

Sensitive source files use chezmoi's age encryption (`encrypted_` prefix):
- `home/dot_ssh/encrypted_config.tmpl` - SSH config with Tailscale host inventory
- `home/dot_zsh/core/encrypted_secrets.zsh` - 1Password/AWS/Infisical integration

Key location: `~/.config/chezmoi/age_key.txt` (mode 600, backed up to 1Password).

New machine bootstrap: `make age-retrieve` pulls the key from 1Password. The age key must exist before `chezmoi apply` or encrypted files will fail to decrypt.

### Tmux

Modern config in `home/dot_tmux.conf.tmpl`:
- Prefix: `Ctrl+a`
- Splits: `|` horizontal, `-` vertical
- Navigation: `hjkl` or `Alt+arrows`
- Synthwave84 status bar

### Hammerspoon (macOS)

Window management in `home/dot_hammerspoon/init.lua`:
- `Cmd+Alt + arrows` - Window halves/full
- `Cmd+Alt + 1-5` - Window thirds
- `Cmd+Alt + t/e/b` - Launch Ghostty/Zed/Brave
- `Cmd+Alt + space` - App chooser
- `Cmd+Alt + v` - Clipboard history

### Neovim

Lean config (~540 lines) in `home/private_dot_config/nvim/`:
- Telescope, Treesitter, LSP+Mason
- mini.files, flash.nvim, gitsigns
- Synthwave84 theme
- `<Space>ff` find files, `<Space>e` explorer

## Adding New Features

### New shell alias
Add to `home/dot_zsh/aliases/dev.zsh`

### New conditional tool
1. Add to `chezmoi.toml`: `mytool = true`
2. Use in templates: `{{- if .mytool -}}...{{- end -}}`

### New setup script
Create `scripts/setup/setup-mytool.sh`, add Makefile target

## Code Style

- Shell: bash with `set -e`, shellcheck compliant
- Chezmoi templates: Use `{{- -}}` to trim whitespace
- Lua (Hammerspoon/Neovim): Follow existing patterns

## Unified Theming

Source: `config/theme/synthwave84.toml`

Applied to: Ghostty, tmux, fzf, Neovim, Starship, Hammerspoon alerts

## Brewfile (macOS)

```bash
make brew-install   # Install all packages
make brew-dump      # Update from current system
```

Includes: fzf, zoxide, eza, bat, fd, ripgrep, delta, gh, tldr, htop, jq, yq
