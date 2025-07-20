# DROO's Dotfiles

[![Plugins](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugins?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Leader Key](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/leaderkey?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Plugin Manager](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugin-manager?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) - featuring modular tool loading, project templates, and development automation.

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              🚀 DROO's Dotfiles Configuration Matrix                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  📊 Status: MIT License | macOS/Linux | Zsh/Bash | 1.3s → 0.4s | Active Development                        │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  🛠️  Core Tools          │  💻 Languages & Runtimes    │  🔧 Version Managers            │
│  ─────────────────────── │  ───────────────────────── │  ──────────────────────────────  │
│  🏠 chezmoi (Latest)     │  🟢 Node.js 23.4.0         │  📦 asdf 0.13.1                  │
│  🐚 Zsh 5.9             │  🐍 Python 3.10.13         │  🔄 direnv 2.32.3                │
│  🐱 Kitty 0.30.1        │  🦀 Rust 1.88.0            │  🐧 devenv 0.10.0                │
│  📝 Neovim 0.10.0       │  💜 Elixir 1.18.3          │  ❄️  Nix 2.18.0                  │
│  🎯 Cursor 0.1.0        │  ☕ Erlang 26.2.4           │  ──────────────────────────────  │
│  ─────────────────────── │  🔵 Lua 5.4.8              │  🛠️  Development Tools          │
│  🎨 Project Templates   │  ───────────────────────── │  ──────────────────────────────  │
│  ─────────────────────── │  📋 Available Templates    │  🔧 Git                          │
│  ⛓️  web3               │  ───────────────────────── │  🐙 GitHub                       │
│  ⚛️  nextjs             │  🏗️  Full-stack blockchain  │  🐳 Docker                       │
│  ⚛️  react              │  ⚛️  Modern React apps      │  🍺 Homebrew                     │
│  🦀 rust                │  🦀 CLI tools & services    │  ✅ Pre-commit                   │
│  💜 elixir              │  💜 Phoenix web apps        │  ──────────────────────────────  │
│  🟢 node                │  🟢 Node.js APIs            │  📊 Performance Tools            │
│  🐍 python              │  🐍 Python applications     │  ──────────────────────────────  │
│  🔵 go                  │  🔵 Go services             │  ⏱️  Startup: 0.4s               │
│  ─────────────────────── │  ───────────────────────── │  💾 Memory: Optimized            │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  🌐 Web3 & Frameworks   │  ⚡ Features & Workflow     │  📊 Performance Metrics          │
│  ─────────────────────── │  ───────────────────────── │  ──────────────────────────────  │
│  ⚡ Ethereum             │  ⚡ Lazy Loading            │  🚀 0.9s Saved per Shell         │
│  🔨 Foundry              │  📋 8 Template Types       │  🧩 Modular Architecture         │
│  🟣 Solana               │  📊 Performance Monitor    │  📊 Performance Monitor          │
│  ⚛️  Next.js            │  ⛓️  Web3 Ready             │  🎯 Auto-completion              │
│  ⚛️  React              │  🚀 0.9s Saved per Shell    │  ──────────────────────────────  │
│  🔷 TypeScript          │  💾 Memory: Optimized       │  ──────────────────────────────  │
│  🎨 Tailwind CSS        │  🎯 Auto-completion        │  ──────────────────────────────  │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

## 🔗 Neovim Plugins

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    🎯 Neovim Plugin Configuration Matrix                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  📊 Status: 50+ plugins | Lazy Loading | Performance Optimized | 15 Categories                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  🎨 UI/Theme              │  💬 Comments              │  ⚡ Completion              │  🔍 Fuzzy Finder        │
│  ───────────────────────── │  ───────────────────────── │  ───────────────────────── │  ─────────────────────  │
│  🌙 twilight.nvim         │  💬 Comment.nvim          │  ⚡ nvim-cmp               │  🔭 telescope.nvim      │
│  🎨 mini.hipatterns       │  ✅ todo-comments.nvim     │  📝 LuaSnip               │  📍 mini.visits         │
│  🌆 synthwave84.nvim      │  💬 ts-context-commentstring│  🧩 friendly-snippets    │  🔍 mini.extra          │
│  ───────────────────────── │  ───────────────────────── │  ───────────────────────── │  ─────────────────────  │
│  📁 File Explorer         │  🛠️  LSP/Diagnostics      │  🐙 Git Integration       │  ⌨️  Keybindings         │
│  ───────────────────────── │  ───────────────────────── │  ───────────────────────── │  ─────────────────────  │
│  📂 mini.files            │  🔧 nvim-lspconfig        │  📊 mini.diff             │  ⌨️  which-key.nvim      │
│  🌳 nvim-tree.lua         │  🛠️  mason.nvim           │  🐙 gitsigns.nvim         │  ⚡ flash.nvim           │
│  ───────────────────────── │  ⚠️  trouble.nvim         │  ───────────────────────── │  ─────────────────────  │
│  📝 Editing               │  📊 Status/Tabs           │  🧪 Testing               │  📚 Note-taking          │
│  ───────────────────────── │  ───────────────────────── │  ───────────────────────── │  ─────────────────────  │
│  🔗 mini.pairs            │  📊 mini.statusline       │  🧪 neotest               │  📖 orgmode              │
│  🔄 mini.surround         │  📊 lualine.nvim          │  🧪 neotest-*             │  📚 neorg                │
│  🤖 mini.ai               │  📊 mini.tabline          │  ───────────────────────── │  ─────────────────────  │
│  ➡️  mini.move            │  ───────────────────────── │  🎨 Fonts                 │  🛠️  Utilities          │
│  ⚙️  mini.operators       │  ───────────────────────── │  🎨 mona.nvim            │  🧩 mini.nvim            │
│  ───────────────────────── │  ───────────────────────── │  ───────────────────────── │  🔊 noice.nvim           │
│  ───────────────────────── │  ───────────────────────── │  ───────────────────────── │  🔔 nvim-notify          │
│  ───────────────────────── │  ───────────────────────── │  ───────────────────────── │  🎛️  dressing.nvim       │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

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
