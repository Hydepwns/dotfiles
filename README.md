# DROO's Dotfiles

[![Plugins](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugins?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Leader Key](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/leaderkey?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Plugin Manager](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugin-manager?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) - featuring modular tool loading, project templates, and development automation.

```bash
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    🚀 DROO's Dotfiles Configuration Matrix                               │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  📊 Status: MIT License | macOS/Linux | Zsh/Bash | 1.3s → 0.4s | Active Development                      │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  🛠️  Core Tools          │  💻 Languages & Runtimes    │  🔧 Version Managers    │  🌐 Web3 & Frameworks │
│  ─────────────────────── │  ───────────────────────── │  ───────────────────── │  ───────────────────────  │
│  🏠 chezmoi (Latest)     │  🟢 Node.js 23.4.0         │  📦 asdf 0.13.1        │  ⚡ Ethereum             │
│  🐚 Zsh 5.9             │  🐍 Python 3.10.13         │  🔄 direnv 2.32.3      │  🔨 Foundry              │
│  🐱 Kitty 0.30.1        │  🦀 Rust 1.88.0            │  🐧 devenv 0.10.0      │  🟣 Solana               │
│  📝 Neovim 0.10.0       │  💜 Elixir 1.18.3          │  ❄️  Nix 2.18.0         │  ⚛️  Next.js            │
│  🎯 Cursor 0.1.0        │  ☕ Erlang 26.2.4           │  ───────────────────── │  ⚛️  React              │
│  ─────────────────────── │  🔵 Lua 5.4.8              │  🛠️  Development Tools  │  🔷 TypeScript          │
│  🎨 Project Templates   │  ───────────────────────── │  ───────────────────── │  🎨 Tailwind CSS          │
│  ─────────────────────── │  📋 Available Templates    │  🔧 Git                │  ───────────────────────  │
│  ⛓️  web3               │  ───────────────────────── │  🐙 GitHub             │  ⚡ Features & Workflow     │
│  ⚛️  nextjs             │  🏗️  Full-stack blockchain  │  🐳 Docker             │  ───────────────────────  │
│  ⚛️  react              │  ⚛️  Modern React apps      │  🍺 Homebrew           │  ⚡ Lazy Loading           │
│  🦀 rust                │  🦀 CLI tools & services    │  ✅ Pre-commit         │  📋 8 Template Types      │
│  💜 elixir              │  💜 Phoenix web apps        │  ───────────────────── │  🧩 Modular Architecture │
│  🟢 node                │  🟢 Node.js APIs            │  📊 Performance Tools  │  📊 Performance Monitor  │
│  🐍 python              │  🐍 Python applications     │  ───────────────────── │  ⛓️  Web3 Ready          │
│  🔵 go                  │  🔵 Go services             │  ⏱️  Startup: 0.4s     │  🚀 0.9s Saved per Shell │
│  ─────────────────────── │  ───────────────────────── │  💾 Memory: Optimized  │  🎯 Auto-completion      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

<!-- markdownlint-disable MD033 -->
<details open>
<summary>🔗 Neovim Plugins</summary>

```bash
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    🎯 Neovim Plugin Configuration Matrix                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  📊 Status: 50+ plugins | Lazy Loading | Performance Optimized | 15 Categories                           │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  🎨 UI/Theme          │  💬 Comments          │  ⚡ Completion        │  🔍 Fuzzy Finder         │
│  ───────────────────── │  ─────────────────── │  ─────────────────── │  ───────────────────── │
│  🌙 twilight.nvim     │   Comment.nvim     │   nvim-cmp         │  🔭 telescope.nvim     │
│  🎨 mini.hipatterns   │  ✅ todo-comments     │   LuaSnip          │  📍 mini.visits        │
│  🌆 synthwave84.nvim  │   ts-context       │   friendly-snippets│  🔍 mini.extra         │
│  ───────────────────── │  ─────────────────── │  ─────────────────── │  ───────────────────── │
│  📁 File Explorer     │   LSP/Diagnostics  │   Git              │  ⌨️  Keybindings       │
│  ───────────────────── │  ─────────────────── │  ─────────────────── │  ───────────────────── │
│  📂 mini.files        │   nvim-lspconfig   │   mini.diff        │  ⌨️  which-key.nvim    │
│  🌳 nvim-tree.lua     │  🛠️  mason.nvim      │   gitsigns.nvim    │  ⚡ flash.nvim         │
│  ───────────────────── │  ⚠️  trouble.nvim    │  ─────────────────── │  ───────────────────── │
│  📝 Editing           │   Status/Tabs      │   Testing          │  📚 Note-taking        │
│  ───────────────────── │  ─────────────────── │  ─────────────────── │  ───────────────────── │
│  🔗 mini.pairs        │   mini.statusline  │   neotest          │  📖 orgmode            │
│  🔄 mini.surround     │   lualine.nvim     │   neotest-*        │   neorg               │
│  🤖 mini.ai           │   mini.tabline     │  ─────────────────── │  ───────────────────── │
│  ➡️  mini.move        │  ─────────────────── │   Fonts            │  🛠️  Utilities         │
│  ⚙️  mini.operators   │  ─────────────────── │  ─────────────────── │  ───────────────────── │
│  ───────────────────── │  ─────────────────── │   mona.nvim       │  🧩 mini.nvim          │
│  ───────────────────── │  ─────────────────── │  ─────────────────── │  🔊 noice.nvim         │
│  ───────────────────── │  ─────────────────── │  ─────────────────── │  🔔 nvim-notify        │
│  ───────────────────── │  ─────────────────── │  ─────────────────── │  🎛️  dressing.nvim     │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

**Key Features**: Lazy loading, modular architecture, performance optimized, 15 categories
</details>
<!-- markdownlint-enable MD033 -->

| Template | 🎨 Icon | 📝 Description | 🛠️ Tech Stack | ⚙️ Options | 📋 Template Types |
|----------|---------|---------------|---------------|------------|-----------------|
| **web3** | ⛓️ | Full-stack blockchain | Ethereum/Foundry, Solana/Anchor | `--web3-type`, `--with-tests`, `--with-ci` | 8 |
| **nextjs** | ⚛️ | Modern React apps | TypeScript, Tailwind, Testing | `--with-tests`, `--with-ci`, `--with-docs` | 8 |
| **react** | ⚛️ | React with Vite | TypeScript, Vite, Testing | `--with-tests`, `--with-ci` | 8 |
| **rust** | 🦀 | CLI tools & services | Rust, Common deps, Web frameworks | `--with-docs`, `--with-ci` | 8 |
| **elixir** | 💜 | Phoenix web apps | Elixir, Phoenix, LiveView | `--with-docs`, `--with-ci` | 8 |
| **node** | 🟢 | Node.js APIs | Node.js, TypeScript, Express | `--with-tests`, `--with-ci` | 8 |
| **python** | 🐍 | Python applications | Python, Virtual env, Testing | `--with-docs`, `--with-ci` | 8 |
| **go** | 🔵 | Go services | Go modules, Testing, CLI | `--with-tests`, `--with-ci` | 8 |

---

## 🚀 Quick Start

### 📦 Install

```bash
curl -fsSL https://raw.githubusercontent.com/hydepwns/dotfiles/main/scripts/setup/quick-setup.sh | bash
```

### 🔄 Alternative

```bash
brew install chezmoi && chezmoi init --apply https://github.com/hydepwns/dotfiles.git
```

## ✨ Key Features

- **🚀 Lazy Loading**: Version managers load only when used (saves 0.9s per shell startup)
- **📊 Performance Monitoring**: Real-time tracking of shell startup times
- **🧩 Modular Configuration**: Organized shell modules in `home/dot_zsh/core/`
- **🎯 Project Templates**: Web3, Next.js, Rust CLI generators

### Performance Metrics

- **Shell Startup**: 1.3s → 0.4s (0.9s saved per startup)
- **Tool Loading**: NVM (0.21s), rbenv (0.06s), pyenv (0.15s) - lazy loaded
- **Memory Usage**: Optimized PATH management and module loading
- **Development Speed**: Pre-configured templates and automation

### ⚡ Lazy Loading Performance Breakdown

| Tool | Eager Load | Lazy Load | Time Saved |
|------|------------|-----------|------------|
| **NVM** | 0.21s | 0.003s | **0.21s** |
| **rbenv** | 0.06s | 0.003s | **0.06s** |
| **pyenv** | 0.15s | 0.003s | **0.15s** |
| **asdf** | 0.008s | 0.003s | **0.005s** |
| **Total** | **0.43s** | **0.012s** | **0.42s** |

> Based on 10-iteration benchmarks on M1 macbook pro

## 🛠️ Usage & Commands

| Category | Command | Description |
|----------|---------|-------------|
| **🏠 Core** | `make install` | Install dotfiles |
| **🔄 Sync** | `make update` | Update from remote |
| **🏥 Health** | `make doctor` | System health check |
| **📡 Sync** | `make sync` | Sync local changes |

### 🎨 Project Generation

```bash
# Quick examples (see template table above for all options)
make generate-template web3 my-project --web3-type both --with-tests --with-ci
make generate-template nextjs my-app --with-tests --with-ci --with-docs
make generate-template rust my-cli --with-docs --with-ci

# List all templates and options
make generate-template
```

### ⚙️ Optional Enhancements

```bash
# Install additional tools
make install-optional

# Setup Cursor IDE
./scripts/setup/setup-cursor-simple.sh

# Performance monitoring
make performance-monitor ACTION=measure
```

---

## ⚙️ Configuration & Setup

### 🎯 Initial Configuration

The setup process will prompt you for:

| Setting | Purpose | Example |
|---------|---------|---------|
| **📧 Email** | Git configuration | `user@example.com` |
| **👤 Username** | Git configuration | `Your Name` |
| **🛠️ Tool Preferences** | Nix, Oh My Zsh, asdf | `y/n` for each tool |
| **💻 Machine Type** | Personal (SSH keys) or Work | `personal` or `work` |

### 🔑 SSH & GitHub Setup (Optional)

```bash
# Set GitHub token for SSH key fetching
export GITHUB_TOKEN="your_personal_access_token"

# Apply configuration with SSH keys
chezmoi apply

# Or use the setup script
./scripts/setup/setup-github-token.sh
```

## 🔧 Command Reference

### 🎯 Core Commands

| Category | Commands | Description |
|----------|----------|-------------|
| **🏠 Core** | `install`, `update`, `diff`, `status` | Basic dotfiles management |
| **🏥 Health** | `doctor`, `bootstrap` | System diagnostics & setup |
| **📡 Sync** | `sync`, `sync-from-remote` | Synchronization operations |
| **⚙️ Optional** | `install-optional`, `performance-monitor` | Additional tools & monitoring |
| **🛠️ Advanced** | `backup`, `clean`, `performance-test` | Maintenance & optimization |

## 🚀 Advanced Usage

```bash
# Edit specific configuration files
chezmoi edit ~/.zshrc
chezmoi edit ~/.gitconfig
chezmoi edit ~/.tmux.conf

# Apply specific templates only
chezmoi apply --source-path ~/.local/share/chezmoi

# Verify configuration integrity
chezmoi verify
```

```bash
# 1. Health check → 2. Backup → 3. Edit → 4. Test → 5. Sync
make doctor && make backup && chezmoi edit ~/.zshrc && make performance-test && make sync
```

```bash
# List all templates and options
make generate-template

# Generate with all options
make generate-template web3 my-project --web3-type both --with-tests --with-ci --with-direnv --with-devenv
```

## 🚨 Troubleshooting & Support

| Issue | 🎯 Quick Fix | 🔍 Diagnostic |
|-------|--------------|---------------|
| **Template errors** | Check chezmoi syntax: `{{-` and `-}}` | `chezmoi verify` |
| **Path issues** | Verify Homebrew prefix for your architecture | `make doctor` |
| **Tool not found** | Install tool before applying configuration | `which <tool>` |
| **Performance issues** | Run performance monitoring | `make performance-monitor ACTION=measure` |
| **Cursor setup** | Use the simple setup script | `./scripts/setup/setup-cursor-simple.sh` |
| **SSH key issues** | Check GitHub token setup | `./scripts/setup/setup-github-token.sh` |

```bash
make doctor                    # System health check
make performance-monitor analyze # Performance analysis
chezmoi verify                 # Configuration verification

make performance-monitor for detailed metrics
make generate-template to see all options
```

---

## 🌟 tldr; launch Gundam?

```bash
curl -fsSL https://raw.githubusercontent.com/hydepwns/dotfiles/main/scripts/setup/quick-setup.sh | bash
```
