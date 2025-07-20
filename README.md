# DROO's Dotfiles

[![Plugins](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugins?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Leader Key](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/leaderkey?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Plugin Manager](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugin-manager?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) - featuring modular tool loading, project templates, and development automation.

## 🚀 Configuration Overview

**Status:** MIT License | macOS/Linux | Zsh/Bash | 1.3s → 0.4s | Active Development

### 🛠️ Core Tools & Languages

| Category | Tools | Languages & Runtimes | Version Managers |
|----------|-------|---------------------|------------------|
| **Core Tools** | 🏠 chezmoi, 🐚 Zsh, 🐱 Kitty, 📝 Neovim, 🎯 Cursor |  Node.js, 🐍 Python,  Rust, 💜 Elixir, ☕ Erlang, 🔵 Lua | 📦 asdf,  direnv,  devenv, ❄️ Nix |
| **Project Templates** | ⛓️ web3, ⚛️ nextjs, ⚛️ react, 🦀 rust, 💜 elixir, 🟢 node,  python, 🔵 go | 🏗️ Full-stack blockchain, ⚛️ Modern React apps, 🦀 CLI tools & services, 💜 Phoenix web apps, 🟢 Node.js APIs, 🐍 Python applications, 🔵 Go services | ️ Development Tools,  Git,  GitHub, 🐳 Docker, 🍺 Homebrew, ✅ Pre-commit, 📊 Performance Tools |

### 🌐 Web3 & Frameworks

| Web3 & Frameworks | Features & Workflow | Performance Metrics |
|-------------------|-------------------|-------------------|
| ⚡ Ethereum, 🔨 Foundry, 🟣 Solana, ⚛️ Next.js, ⚛️ React, 🔷 TypeScript, 🎨 Tailwind CSS | ⚡ Lazy Loading, 📋 8 Template Types, 📊 Performance Monitor, ⛓️ Web3 Ready, 🚀 0.9s Saved per Shell, 💾 Memory: Optimized, 🎯 Auto-completion | 🚀 0.9s Saved per Shell, 🧩 Modular Architecture, 📊 Performance Monitor, 🎯 Auto-completion |

## 🔗 Neovim Plugins

**Status:** 50+ plugins | Lazy Loading | Performance Optimized | 15 Categories

### 🎨 UI & Theme

| Plugin | Description |
|--------|-------------|
| 🌙 twilight.nvim, 🎨 mini.hipatterns, 🌆 synthwave84.nvim | Focus mode, pattern highlighting, retro theme |

### 💬 Comments & Completion

| Category | Plugins |
|----------|---------|
| **Comments** | 💬 Comment.nvim, ✅ todo-comments.nvim, 💬 ts-context-commentstring |
| **Completion** | ⚡ nvim-cmp, 📝 LuaSnip, 🧩 friendly-snippets |

### 📁 File Management & Git

| Category | Plugins |
|----------|---------|
| **File Explorer** | 📂 mini.files, 🌳 nvim-tree.lua |
| **Git Integration** | 🐙 gitsigns.nvim, 📊 mini.diff |

### 🛠️ LSP & Diagnostics

| Category | Plugins |
|----------|---------|
| **LSP** | 🔧 nvim-lspconfig, 🛠️ mason.nvim |
| **Diagnostics** | ⚠️ trouble.nvim |

### 📝 Editing & Movement

| Category | Plugins |
|----------|---------|
| **Editing** | 🔗 mini.pairs, 🔄 mini.surround, 🤖 mini.ai |
| **Movement** | ➡️ mini.move, ⚙️ mini.operators |

### 📊 Status & Testing

| Category | Plugins |
|----------|---------|
| **Status/Tabs** | 📊 mini.statusline, 📊 lualine.nvim, 📊 mini.tabline |
| **Testing** | 🧪 neotest, 🧪 neotest-* |

### 🔍 Fuzzy Finder & Keybindings

| Category | Plugins |
|----------|---------|
| **Fuzzy Finder** | 🔭 telescope.nvim, 📍 mini.visits, 🔍 mini.extra |
| **Keybindings** | ⌨️ which-key.nvim, ⚡ flash.nvim |

### 📚 Note-taking & Utilities

| Category | Plugins |
|----------|---------|
| **Note-taking** | 📖 orgmode, 📚 neorg |
| **Utilities** | 🧩 mini.nvim, 🔊 noice.nvim, 🔔 nvim-notify, 🎛️ dressing.nvim |

### 🎨 Fonts

| Plugin | Description |
|--------|-------------|
| 🎨 mona.nvim | Custom font support |

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
