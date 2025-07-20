# DROO's Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) - featuring modular tool loading, project templates, and development automation.

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

### 🛠️ Core Tools

- **Shell**: Zsh with Oh My Zsh, modular cross-platform support
- **Terminal**: Kitty with One Dark Pro theme, Monaspace font
- **Git**: Work/personal separation, SSH with GitHub key fetching
- **Editors**: Neovim (LazyNvim), Zed, VS Code integration
- **Package Managers**: Homebrew, pnpm, pipx

### 🎯 Development Languages

- **Rust**: Full toolchain with Cargo
- **Node.js**: NVM support
- **Python**: pipx for global tools
- **Elixir**: Mix and Kiex support
- **Lua**: LuaRocks and Luaenv
- **Go**: Standard toolchain

### 🚀 Project Templates

- **Web3**: Ethereum/Foundry and Solana/Anchor development
- **Next.js**: TypeScript, Tailwind, testing setup
- **Rust**: Common dependencies and web framework options

## ⚙️ Configuration

The setup prompts for your preferences:

- Email and full name
- Work vs personal machine
- Which tools you use (Nix, Oh My Zsh, asdf, etc.)

### SSH Setup (Optional)

```bash
# 1. Create GitHub token with 'read:user' scope
export GITHUB_TOKEN="your_token_here"

# 2. Apply configuration
chezmoi apply
```

## 🎨 Editor Configurations

### Neovim

- **LazyNvim** with lazy loading
- **synthwave84.nvim** retro colorscheme
- Comprehensive plugin suite (Telescope, Treesitter, LSP, Mason)

### Zed

- **Monaspace Variable** font with ligatures
- **One Dark Pro** theme
- Pre-configured for Rust, TypeScript, Python, Go, Elixir, Lua

### Kitty Terminal

- **One Dark Pro** theme (matches Zed editor)
- **Monaspace Variable** font with coding ligatures
- Development shortcuts for project navigation and tools

## 🏗️ Architecture

### Modular Shell Configuration

- **Core modules**: paths, platforms, tools, config
- **Centralized PATH management** - Single source of truth for all tool paths
- **DRY principles** - Eliminated code duplication across files
- **Cross-platform compatibility** with standardized shebangs

### Centralized PATH Management

All tool paths are managed through a comprehensive registry system in `home/dot_zsh/core/paths.zsh`:

- Version managers (rbenv, nvm, asdf, erlang, elixir, lua)
- Development tools (LLVM, PostgreSQL, Python)
- Web3 tools (Foundry, Huff, Solana)
- Package managers (Homebrew, pnpm, pipx)
- Nix paths

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

### Core Operations

- `make install` - Install dotfiles
- `make update` - Update from remote
- `make diff` - Show differences
- `make status` - Show status

### Backup Operations

- `make backup` - Create backup
- `make backup-full` - Create full backup with archive
- `make clean` - Clean up temporary files and backups

### Health and Maintenance

- `make doctor` - Health check
- `make bootstrap` - Run bootstrap script

### Sync Operations

- `make sync` - Sync local changes
- `make sync-from-remote` - Sync from remote

### Optional Commands

- `make install-optional` - Install optional tools interactively

### Testing and Development

- `make performance-test` - Run performance tests
- `make generate-template` - Generate project templates
- `make tool-versions` - Update tool versions
- `make setup-ci` - Setup CI/CD tools and pre-commit hooks

## 🚨 Troubleshooting

- **Template errors**: Check chezmoi syntax with `{{-` and `-}}`
- **Path issues**: Verify Homebrew prefix for your architecture
- **Tool not found**: Install tool before applying configuration
- **Project templates**: Use `make generate-template` for help
- **Shell issues**: Check modular configuration in `home/dot_zsh/core/`
- **PATH problems**: All PATH management is centralized in `home/dot_zsh/core/paths.zsh`

## 📄 License

MIT License - see LICENSE file for details.
