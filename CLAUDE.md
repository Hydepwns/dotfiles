# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chezmoi-based cross-platform dotfiles with modular zsh configuration. Primary platform is macOS (Apple Silicon), with Linux/NixOS support. Uses template-driven configuration with 30+ conditional features and achieves ~386ms shell startup via caching and lazy-loading.

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
make lint                 # Run shellcheck on all shell scripts
make doctor               # Health check all configs and tools
make perf                 # Benchmark shell startup time

# Setup tools
make setup-secrets        # Install 1Password CLI, AWS CLI, Infisical, Tailscale
make brew-install         # Install all Brewfile packages
make setup-takopi         # Install takopi via uv
make takopi-onboard       # Interactive takopi setup wizard
make takopi-backup        # Encrypt takopi config to chezmoi

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
| `home/private_dot_config/btop/` | `~/.config/btop/` | System monitor + Synthwave84 theme |
| `home/private_dot_config/yazi/` | `~/.config/yazi/` | Terminal file manager |
| `home/private_dot_config/fastfetch/` | `~/.config/fastfetch/` | System info display |
| `home/private_dot_config/starship/` | `~/.config/starship/` | Starship prompt config |
| `home/private_dot_config/direnv/` | `~/.config/direnv/` | direnv layouts (mise, poetry, node) |
| `home/dot_takopi/` | `~/.takopi/` | takopi config (encrypted) |
| `config/raycast/` | Manual deploy | Raycast settings export |
| `config/` | Manual deploy | Theme source of truth |
| `scripts/setup/` | - | Installation scripts |
| `scripts/utils/` | - | Maintenance utilities |

### Modular Zsh Architecture

```
home/dot_zsh/
├── modules.zsh           # Loader
├── core/
│   ├── lazy-loading.zsh  # mise activation, deferred init for direnv
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

Configured in `core/tools.zsh.tmpl` with Synthwave84 theme colors. Includes zsh completions for mise, chezmoi, and make targets.

| Tool | Alias | Usage |
|------|-------|-------|
| fzf | `fe`, `fcd`, `fkill`, `fh`, `fbr` | `Ctrl+R` history, `Ctrl+T` files, `Alt+C` cd |
| zoxide | `z` | Smart cd (`z proj` jumps to project) |
| eza | `ls`, `ll`, `la`, `lt` | Better ls with icons/git |
| bat | `cat`, `catp`, `catl` | Syntax highlighted cat, man pager |
| fd | `find` | Faster find, respects .gitignore |
| ripgrep | `grep`, `rg`, `rgi`, `rgl` | Faster grep |
| yazi | `y` | Terminal file manager with image/PDF/archive preview |
| btop | `top`, `htop` | System monitor (Synthwave84 themed) |
| fastfetch | `fetch`, `neofetch` | System info display |
| jq / yq | - | JSON and YAML processing |
| tldr | `help` | Simplified command examples |
| tree | - | Directory tree view |

### Secrets Management

Three-tier approach in `core/secrets.zsh`:
1. **1Password** (primary) - SSH agent via `SSH_AUTH_SOCK`
2. **AWS CLI** - SSO with `aws-profile <name>`
3. **Infisical** (backup) - `inf-env <environment>`

### Age Encryption

Sensitive source files use chezmoi's age encryption (`encrypted_` prefix):
- `home/dot_ssh/encrypted_config.tmpl` - SSH config with Tailscale host inventory
- `home/dot_zsh/core/encrypted_secrets.zsh` - 1Password/AWS/Infisical integration
- `home/dot_takopi/encrypted_takopi.toml` - takopi Telegram bot config

Key location: `~/.config/chezmoi/age_key.txt` (mode 600, backed up to 1Password).

New machine bootstrap: `make age-retrieve` pulls the key from 1Password. The age key must exist before `chezmoi apply` or encrypted files will fail to decrypt.

### Tmux

Modern config in `home/dot_tmux.conf.tmpl`:
- Prefix: `Ctrl+a`
- Splits: `|` horizontal, `-` vertical
- Navigation: `hjkl` or `Alt+arrows`
- Synthwave84 status bar

### Hammerspoon (macOS)

Window management in `home/dot_hammerspoon/init.lua.tmpl`, gated by `paperwm` chezmoi flag:

**PaperWM mode** (`paperwm = true`) - scrollable tiling:
- `Cmd+Alt + hjkl` - Focus left/right/down/up
- `Cmd+Alt+Shift + hjkl` - Swap windows
- `Cmd+Alt + r` - Cycle window width (1/3, 1/2, 2/3)
- `Cmd+Alt + return` - Full width
- `Cmd+Alt + c` - Center window
- `Cmd+Alt + i/o` - Slurp/barf columns
- `Cmd+Alt+Shift + space` - Toggle floating
- `Cmd+Alt + 1-9` - Switch space
- `Cmd+Alt+Shift + 1-9` - Move window to space
- Setup: `make setup-paperwm`

**Grid mode** (`paperwm = false`) - traditional snapping:
- `Cmd+Alt + arrows` - Window halves/full
- `Cmd+Alt + 1-5` - Window thirds

**Shared bindings** (both modes):
- `Hyper + h/l` - Move window between screens
- `Cmd+Alt + t/e/b` - Launch Ghostty/Zed/Brave
- `Cmd+Alt + space` - App chooser
- `Cmd+Alt + v` - Clipboard history

### Raycast (macOS)

Settings export/import via `config/raycast/`:
- `make raycast-export` -- opens Raycast export dialog, decompresses `.rayconfig` to `settings.json` for diffable version control
- `make raycast-import` -- opens Raycast import dialog to restore from `.rayconfig`
- `make raycast-status` -- show installation and export status
- Gated by `raycast = true` in chezmoi.toml

### Neovim

27 plugins across 8 modules in `home/private_dot_config/nvim/`:
- Telescope, Treesitter, LSP+Mason, nvim-cmp
- mini.files, mini.surround, mini.statusline, mini.indentscope
- flash.nvim, gitsigns, lazygit, which-key, trouble, conform
- mona.nvim (Synthwave84 colorscheme)
- `<Space>ff` find files, `<Space>e` explorer

### Starship Prompt

Synthwave84-themed cross-shell prompt in `home/private_dot_config/starship/starship.toml.tmpl`:
- Git branch (pink), status (yellow), state (rebase/merge indicator)
- Language versions: node, rust, python, elixir, go (contextual)
- Command duration (>2s), error status, SSH-aware username/hostname
- Directory substitutions: `Documents` -> `docs`, `CODE` -> `code`
- Gated by `starship = true` in chezmoi.toml (disables Oh My Zsh theme)

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

Applied to: Ghostty, tmux, fzf, Neovim (mona.nvim), btop, yazi, fastfetch, Starship, Hammerspoon alerts

## Brewfile (macOS)

```bash
make brew-install   # Install all packages
make brew-dump      # Update from current system
```

Includes: fzf, zoxide, eza, bat, fd, ripgrep, delta, gh, tldr, btop, fastfetch, yazi, jq, yq, tree, direnv
