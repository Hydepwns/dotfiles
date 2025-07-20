# DROO's Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) - featuring modular tool loading, project templates, and development automation.

[![CI](https://github.com/hydepwns/dotfiles/workflows/CI/badge.svg)](https://github.com/hydepwns/dotfiles/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![chezmoi](https://img.shields.io/badge/chezmoi-managed-blue.svg)](https://www.chezmoi.io/)

## 🚀 Quick Start

### One-Command Setup (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/hydepwns/dotfiles/main/scripts/setup/quick-setup.sh | bash
```

### Alternative Setup Options

```bash
# Manual setup
brew install chezmoi && chezmoi init --apply https://github.com/hydepwns/dotfiles.git

# Full bootstrap (with dependencies)
curl -fsSL https://raw.githubusercontent.com/hydepwns/dotfiles/main/scripts/setup/bootstrap.sh | bash
```

### Setup Scripts Reference

| Script | Purpose | Use Case |
|--------|---------|----------|
| `quick-setup.sh` | One-command setup | New machines |
| `bootstrap.sh` | Complete setup | Full system with dependencies |
| `setup-cursor.sh` | Cursor IDE config | After initial setup |
| `setup-ci.sh` | CI/CD tools | Development workflow |

## ✨ Key Features

- **🚀 Lazy Loading**: Version managers load only when used (~48% faster startup)
- **📊 Performance Monitoring**: Real-time tracking of shell startup times
- **🧩 Modular Configuration**: Organized shell modules in `home/dot_zsh/core/`
- **🎯 Project Templates**: Web3, Next.js, Rust CLI generators

### Performance Metrics
- **Shell Startup**: Reduced from 2.69s to 1.40s (~48% improvement)
- **Tool Loading**: Lazy-loaded version managers (NVM, rbenv, asdf, direnv)
- **Memory Usage**: Optimized PATH management and module loading
- **Development Speed**: Pre-configured templates and automation

## 🛠️ Development Stack

| Category | Tools |
|----------|-------|
| **Shell & Terminal** | ![Zsh](https://img.shields.io/badge/Zsh-1.2.0-000000?style=flat&logo=gnu-bash&logoColor=white) ![Kitty](https://img.shields.io/badge/Kitty-0.30.1-000000?style=flat&logo=kitty&logoColor=white) |
| **Editors & IDEs** | ![Neovim](https://img.shields.io/badge/Neovim-57C3C2?style=flat&logo=neovim&logoColor=white) ![Zed](https://img.shields.io/badge/Zed-000000?style=flat&logo=zed&logoColor=white) ![Cursor](https://img.shields.io/badge/Cursor-000000?style=flat&logo=cursor&logoColor=white) |
| **Languages** | ![Rust](https://img.shields.io/badge/Rust-000000?style=flat&logo=rust&logoColor=white) ![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white) ![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white) ![Go](https://img.shields.io/badge/Go-00ADD8?style=flat&logo=go&logoColor=white) ![Elixir](https://img.shields.io/badge/Elixir-4B275F?style=flat&logo=elixir&logoColor=white) ![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat&logo=lua&logoColor=white) |
| **Web3 & Frameworks** | ![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=flat&logo=ethereum&logoColor=white) ![Foundry](https://img.shields.io/badge/Foundry-000000?style=flat&logo=foundry&logoColor=white) ![Solana](https://img.shields.io/badge/Solana-14F46D?style=flat&logo=solana&logoColor=white) ![Next.js](https://img.shields.io/badge/Next.js-000000?style=flat&logo=nextdotjs&logoColor=white) |
| **Version Managers** | ![asdf](https://img.shields.io/badge/asdf-000000?style=flat&logo=asdf&logoColor=white) ![NVM](https://img.shields.io/badge/NVM-000000?style=flat&logo=nvm&logoColor=white) ![rbenv](https://img.shields.io/badge/rbenv-000000?style=flat&logo=ruby&logoColor=white) ![direnv](https://img.shields.io/badge/direnv-000000?style=flat&logo=direnv&logoColor=white) |

### Project Templates

| Template | Description | Tech Stack |
|----------|-------------|------------|
| **Web3 Development** | Full-stack blockchain | Ethereum/Foundry, Solana/Anchor |
| **Next.js App** | Modern React apps | TypeScript, Tailwind, Testing |
| **React App** | React with Vite | TypeScript, Vite, Testing |
| **Rust CLI** | Command-line tools | Rust, Common deps, Web frameworks |
| **Elixir Phoenix** | Web applications | Elixir, Phoenix, LiveView |
| **Node.js API** | Backend services | Node.js, TypeScript, Express |
| **Python App** | Python applications | Python, Virtual env, Testing |
| **Go Service** | Go applications | Go modules, Testing, CLI |

## 🛠️ Usage

### Essential Commands

```bash
# Core operations
make install          # Install dotfiles
make update           # Update from remote
make doctor           # Health check
make sync             # Sync local changes

# Project generation
make generate-template web3 my-defi-project ethereum solana
make generate-template nextjs my-webapp typescript tailwind jest
make generate-template rust my-cli-tool
make generate-template elixir my-phoenix-app
make generate-template react my-react-app --with-tests
make generate-template python my-python-app --with-docs
make generate-template go my-go-service --with-ci
```

### Optional Setup

```bash
# Install optional tools
make install-optional

# Setup Cursor IDE
./scripts/setup/setup-cursor-simple.sh

# Performance monitoring
make performance-monitor ACTION=measure
```

## ⚙️ Configuration

### Initial Setup

The setup prompts for:

- **Email & username** - Git configuration
- **Tool preferences** - Nix, Oh My Zsh, asdf, etc.
- **Machine type** - Personal (includes SSH keys) or work

### SSH Setup (Optional)

```bash
export GITHUB_TOKEN="your_token_here"
chezmoi apply
```

## 🔧 Command Reference

| Category | Commands |
|----------|---------|
| **Core** | `install`, `update`, `diff`, `status` |
| **Health** | `doctor`, `bootstrap` |
| **Sync** | `sync`, `sync-from-remote` |
| **Optional** | `install-optional`, `performance-monitor` |

## 🚀 Advanced Usage

### Customization
```bash
# Edit configuration
chezmoi edit ~/.zshrc

# Apply specific templates
chezmoi apply --source-path ~/.local/share/chezmoi

# Check configuration
chezmoi verify
```

### Development Workflow
```bash
# Performance testing
make performance-test

# Health monitoring
make doctor

# Backup before changes
make backup

# Sync changes
make sync
```

### Template Options
```bash
# Generate with specific options
make generate-template web3 my-project --web3-type both --with-tests --with-ci

# List available templates
make generate-template

# Update tool versions
make tool-versions COMMAND=update
```

## 🚨 Quick Troubleshooting

| Issue | Quick Fix |
|-------|-----------|
| **Template errors** | Check chezmoi syntax: `{{-` and `-}}` |
| **Path issues** | Verify Homebrew prefix for your architecture |
| **Tool not found** | Install tool before applying configuration |
| **Performance issues** | Run `make performance-monitor ACTION=measure` |
| **Cursor setup** | Use `./scripts/setup/setup-cursor-simple.sh` |

## 🆘 Getting Help

- **Documentation**: Check `home/dot_zsh/core/` for modular configuration
- **Templates**: Use `make generate-template` for project help
- **Performance**: Use `make performance-monitor` for diagnostics
- **Issues**: Check the troubleshooting table above

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Quick Start for Contributors
```bash
# Fork and clone the repository
git clone https://github.com/your-username/dotfiles.git
cd dotfiles

# Setup development environment
make bootstrap

# Make your changes
chezmoi edit ~/.zshrc

# Test your changes
make doctor
make performance-test

# Commit and push
make sync
```

### Contribution Guidelines
- **Test changes**: Run `make doctor` and `make performance-test`
- **Follow conventions**: Use existing patterns and structure
- **Document updates**: Update README for new features
- **Performance**: Ensure changes don't impact startup time

### Areas for Contribution
- **New templates**: Add project templates for other frameworks
- **Performance**: Optimize shell startup and tool loading
- **Documentation**: Improve guides and examples
- **Testing**: Add more comprehensive test coverage

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
