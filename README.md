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
| **Core Tools** | 🏠 chezmoi (Latest)<br>🐚 Zsh 5.9<br>🐱 Kitty 0.30.1<br>📝 Neovim 0.10.0<br>🎯 Cursor 0.1.0 | 🟢 Node.js 23.4.0<br>🐍 Python 3.10.13<br>🦀 Rust 1.88.0<br>💜 Elixir 1.18.3<br>☕ Erlang 26.2.4<br>🔵 Lua 5.4.8 | 📦 asdf 0.13.1<br>🔄 direnv 2.32.3<br>🐧 devenv 0.10.0<br>❄️ Nix 2.18.0 |
| **Project Templates** | ⛓️ web3<br>⚛️ nextjs<br>⚛️ react<br>🦀 rust<br>💜 elixir<br>🟢 node<br>🐍 python<br>🔵 go | 🏗️ Full-stack blockchain<br>⚛️ Modern React apps<br>🦀 CLI tools & services<br>💜 Phoenix web apps<br>🟢 Node.js APIs<br>🐍 Python applications<br>🔵 Go services | 🛠️ Development Tools<br>🔧 Git<br>🐙 GitHub<br>🐳 Docker<br>🍺 Homebrew<br>✅ Pre-commit<br>📊 Performance Tools |

### 🌐 Web3 & Frameworks

| Web3 & Frameworks | Features & Workflow | Performance Metrics |
|-------------------|-------------------|-------------------|
| ⚡ Ethereum<br>🔨 Foundry<br>🟣 Solana<br>⚛️ Next.js<br>⚛️ React<br>🔷 TypeScript<br>🎨 Tailwind CSS | ⚡ Lazy Loading<br>📋 8 Template Types<br>📊 Performance Monitor<br>⛓️ Web3 Ready<br>🚀 0.9s Saved per Shell<br>💾 Memory: Optimized<br>🎯 Auto-completion | 🚀 0.9s Saved per Shell<br>🧩 Modular Architecture<br>📊 Performance Monitor<br>🎯 Auto-completion<br>─<br>─<br>─ |

## 🔗 Neovim Plugins

**Status:** 50+ plugins | Lazy Loading | Performance Optimized | 15 Categories

### 🎨 UI & Theme
| Plugin | Description |
|--------|-------------|
| 🌙 twilight.nvim | Focus mode with dimmed code |
| 🎨 mini.hipatterns | Highlight patterns in text |
| 🌆 synthwave84.nvim | Retro synthwave theme |

### 💬 Comments & Completion
| Comments | Completion |
|----------|------------|
| 💬 Comment.nvim | Smart commenting |
| ✅ todo-comments.nvim | TODO comment highlighting |
| 💬 ts-context-commentstring | Context-aware comments |
| ⚡ nvim-cmp | Smart completion |
| 📝 LuaSnip | Snippet engine |
| 🧩 friendly-snippets | Pre-configured snippets |

### 📁 File Management & Git
| File Explorer | Git Integration |
|---------------|-----------------|
| 📂 mini.files | Minimal file explorer |
| 🌳 nvim-tree.lua | Tree file explorer |
| 🐙 gitsigns.nvim | Git status in gutter |
| 📊 mini.diff | Inline diff highlighting |

### 🛠️ LSP & Diagnostics
| LSP | Diagnostics |
|-----|--------------|
| 🔧 nvim-lspconfig | LSP configuration |
| 🛠️ mason.nvim | Package manager for LSP |
| ⚠️ trouble.nvim | Pretty diagnostics |

### 📝 Editing & Movement
| Editing | Movement |
|---------|----------|
| 🔗 mini.pairs | Auto-pairing brackets |
| 🔄 mini.surround | Surround text objects |
| 🤖 mini.ai | Text object improvements |
| ➡️ mini.move | Move lines/blocks |
| ⚙️ mini.operators | Text operators |

### 📊 Status & Testing
| Status/Tabs | Testing |
|-------------|---------|
| 📊 mini.statusline | Minimal statusline |
| 📊 lualine.nvim | Fancy statusline |
| 📊 mini.tabline | Tab line |
| 🧪 neotest | Testing framework |
| 🧪 neotest-* | Test adapters |

### 🔍 Fuzzy Finder & Keybindings
| Fuzzy Finder | Keybindings |
|--------------|-------------|
| 🔭 telescope.nvim | Fuzzy finder |
| 📍 mini.visits | Jump to files |
| 🔍 mini.extra | Additional pickers |
| ⌨️ which-key.nvim | Key binding hints |
| ⚡ flash.nvim | Enhanced search |

### 📚 Note-taking & Utilities
| Note-taking | Utilities |
|-------------|-----------|
| 📖 orgmode | Org mode support |
| 📚 neorg | Modern note-taking |
| 🧩 mini.nvim | Core utilities |
| 🔊 noice.nvim | UI improvements |
| 🔔 nvim-notify | Notifications |
| 🎛️ dressing.nvim | UI components |

### 🎨 Fonts
| Font |
|------|
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
