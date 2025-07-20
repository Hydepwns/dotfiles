# DROO's Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/) - cross-platform dotfiles with conditional tool loading and modular project templates.

## 🚀 Quick Start

```bash
# Install chezmoi
brew install chezmoi  # macOS
# or
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $USER  # Linux

# Initialize and apply
chezmoi init --apply https://github.com/hydepwns/dotfiles.git
```

## ✨ Features

### Core Tools

- **Shell**: Zsh with Oh My Zsh, modular cross-platform support
- **Terminal**: Kitty with One Dark Pro theme, Monaspace font, development shortcuts
- **Git**: Work/personal separation, SSH with GitHub key fetching
- **Editors**: Neovim (LazyNvim), Zed, VS Code integration
- **Package Managers**: Homebrew, pnpm, pipx
- **Project Templates**: Modular template system for rapid project scaffolding

### Development Languages

- **Rust**: Full toolchain with Cargo
- **Node.js**: NVM support
- **Python**: pipx for global tools
- **Elixir**: Mix and Kiex support
- **Lua**: LuaRocks and Luaenv
- **Go**: Standard toolchain

### Platform-Specific

- **macOS**: Homebrew, iTerm2, OrbStack, Solana, Foundry, Huff
- **Linux**: Enhanced SSH support

## ⚙️ Configuration

The setup prompts for your preferences:

- Email and full name
- Work vs personal machine
- Which tools you use (Nix, Oh My Zsh, asdf, etc.)

### SSH Setup (Optional)

```bash
# 1. Create GitHub token with 'read:user' scope
export GITHUB_TOKEN="your_token_here"

# 2. Install 1Password CLI (optional)
brew install --cask 1password-cli

# 3. Apply configuration
chezmoi apply
```

## 🎨 Editor Configurations

### Neovim

- **LazyNvim** with lazy loading
- **synthwave84.nvim** retro colorscheme
- **Monaspace font** management
- Comprehensive plugin suite (Telescope, Treesitter, LSP, Mason)

### Zed

- **Monaspace Variable** font with ligatures
- **One Dark Pro** theme
- Development-focused settings
- Pre-configured for Rust, TypeScript, Python, Go, Elixir, Lua, et al.

### Kitty Terminal

- **One Dark Pro** theme (matches Zed editor)
- **Monaspace Variable** font with coding ligatures
- **Development shortcuts** for project navigation, editors, and tools
- **Modular configuration** with themes, keybindings, and sessions
- **Cross-platform** support (macOS/Linux)
- **Shell integration** with zsh
- **Predefined sessions** for different development workflows

## 🏗️ Architecture

### Modular Shell Configuration

- **Core modules**: paths, platforms, tools, config
- **Centralized PATH management** for consistent environment
- **DRY principles** through shared configurations

### Project Templates

- **Web3**: Ethereum/Foundry and Solana/Anchor development
- **Next.js**: TypeScript, Tailwind, testing setup
- **Rust**: Common dependencies and web framework options
- **Extensible**: Easy addition of new template types

## 📁 Structure

```bash
.
├── home/                    # ~/.dotfiles
│   └── dot_zsh/
│       ├── core/           # Modular shell configuration
│       │   ├── paths.zsh   # Centralized PATH management
│       │   ├── platforms/  # OS-specific configurations
│       │   ├── tools.zsh   # Tool-specific environments
│       │   └── config.zsh  # Configuration registry
│       └── aliases/        # Shell aliases
├── config/                  # ~/.config
│   ├── kitty/              # Terminal configuration
│   ├── nvim/               # Neovim configuration
│   └── zed/                # Zed editor configuration
├── scripts/                 # Utility scripts
│   ├── setup/              # Installation scripts
│   ├── utils/              # Modular script utilities
│   └── templates/          # Project template generators
├── .chezmoi.toml           # Configuration
└── Makefile                # Common commands
```

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
```

## 🔧 Available Commands

Run `make help` to see all available commands:

- `make install` - Install dotfiles
- `make update` - Update from remote
- `make diff` - Show differences
- `make backup` - Create backup
- `make doctor` - Health check
- `make sync` - Sync local changes
- `make install-optional` - Install optional tools
- `make generate-template` - Generate project templates
- `make tool-versions` - Update tool versions

## 🚨 Troubleshooting

- **Template errors**: Check chezmoi syntax with `{{-` and `-}}`
- **Path issues**: Verify Homebrew prefix for your architecture
- **Tool not found**: Install tool before applying configuration
- **Project templates**: Use `make generate-template` for help
- **Shell issues**: Check modular configuration in `home/dot_zsh/core/`

## 📄 License

MIT License - see LICENSE file for details.
