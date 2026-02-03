# DROO's Dotfiles

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/Hydepwns/dotfiles)

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io) - featuring modular zsh, unified Synthwave84 theming, terminal power tools, and secrets management.

## Quick Start

```bash
# Full bootstrap (installs everything)
curl -fsSL https://raw.githubusercontent.com/Hydepwns/dotfiles/main/scripts/install/remote-bootstrap.sh | bash

# Minimal install
brew install chezmoi && chezmoi init --apply https://github.com/Hydepwns/dotfiles.git
```

## What's Included

| Category | Tools |
|----------|-------|
| **Terminal** | Ghostty + Synthwave84 theme |
| **Editor** | Zed, Neovim (lean config) |
| **Shell** | Zsh + Starship + fzf + zoxide |
| **Terminal Tools** | eza, bat, fd, ripgrep, delta |
| **Window Mgmt** | Hammerspoon (macOS) |
| **Multiplexer** | tmux with modern config |
| **Secrets** | 1Password, AWS CLI, Infisical |
| **Network** | Tailscale with pre-configured hosts |
| **Languages** | Elixir, Node.js, Rust, Python, Go, Lua |

## Terminal Power Tools

| Tool | Replaces | Key Binding / Alias |
|------|----------|---------------------|
| fzf | - | `Ctrl+R` history, `Ctrl+T` files, `Alt+C` cd |
| zoxide | cd | `z` - smart jump (`z proj` -> `/path/to/project`) |
| eza | ls | `ls`, `ll`, `la`, `lt` - icons + git status |
| bat | cat | `cat` - syntax highlighting |
| fd | find | `find` - faster, respects .gitignore |
| ripgrep | grep | `grep`, `rg` - faster search |
| delta | diff | Git diffs with syntax highlighting |

## Key Bindings

### Hammerspoon (macOS)

| Key | Action |
|-----|--------|
| `Cmd+Alt + arrows` | Window halves / full / center |
| `Cmd+Alt + 1-5` | Window thirds |
| `Cmd+Alt + t` | Ghostty |
| `Cmd+Alt + e` | Zed |
| `Cmd+Alt + b` | Brave Browser |
| `Cmd+Alt + space` | App chooser |
| `Cmd+Alt + v` | Clipboard history |
| `Hyper + q` | Lock screen |

### tmux

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix (instead of Ctrl+b) |
| `\|` | Split horizontal |
| `-` | Split vertical |
| `hjkl` | Navigate panes |
| `Shift + arrows` | Switch windows |

### Neovim

| Key | Action |
|-----|--------|
| `Space + ff` | Find files (Telescope) |
| `Space + fg` | Live grep |
| `Space + e` | File explorer |
| `s` | Flash jump |
| `gd` | Go to definition |

## Commands

```bash
# Chezmoi
make install          # Fresh install
make update           # Pull and apply remote
chezmoi apply         # Apply local changes

# Tools
make brew-install     # Install Brewfile packages
make setup-secrets    # Install 1Password, AWS, Infisical, Tailscale
make dashboard        # Service status dashboard

# SSH
make rotate-keys      # Generate, store in 1Password, sync to hosts
make sync-keys        # Sync public key to Tailscale nodes
```

## Secrets Management

| Provider | Purpose | Quick Commands |
|----------|---------|----------------|
| **1Password** | Primary secrets, SSH agent | `opl`, `opw` |
| **AWS CLI** | Cloud credentials | `awsw`, `aws-profile` |
| **Infisical** | Backup secrets | `infl`, `inf-env` |

## Configuration

Edit `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
starship = true
tailscale = true
onepassword = true
aws = true
elixir = true
nodejs = true
```

## Directory Structure

```
dotfiles/
├── home/
│   ├── dot_zsh/                    # Modular zsh
│   │   └── core/tools.zsh          # fzf/zoxide/eza/bat
│   ├── dot_hammerspoon/            # Window management
│   ├── dot_tmux.conf.tmpl          # Modern tmux
│   ├── private_dot_config/
│   │   ├── ghostty/                # Terminal
│   │   ├── zed/                    # Editor
│   │   └── nvim/                   # Neovim (lean)
│   └── dot_claude/                 # Claude Code prefs
├── config/
│   ├── theme/synthwave84.toml      # Theme source
│   └── starship/                   # Prompt config
├── Brewfile                        # macOS packages
└── scripts/
    ├── setup/                      # Installation
    └── utils/                      # Maintenance
```

## Theming

Unified Synthwave84 theme across all tools:
- Ghostty terminal
- tmux status bar
- fzf colors
- Neovim colorscheme
- Starship prompt
- Hammerspoon alerts

Source: `config/theme/synthwave84.toml`

## Related

- [nix-mox](https://github.com/Hydepwns/nix-mox) - Nix Home Manager configuration
- [synthwave84-zed](https://github.com/Hydepwns/synthwave84-zed) - Synthwave84 theme for Zed

---

[chezmoi]: https://chezmoi.io
