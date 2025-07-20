# DROO's Dotfiles

[![Plugins](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugins?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Leader Key](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/leaderkey?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Plugin Manager](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugin-manager?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) - featuring modular tool loading, project templates, and development automation.

## 🚀 Configuration Overview

### 🛠️ Core Tools & Languages

| Category | Tools | Languages & Runtimes | Version Managers |
|----------|-------|---------------------|------------------|
| **Core Tools** | [![chezmoi](https://img.shields.io/badge/chezmoi-Latest-blue.svg)](https://www.chezmoi.io/) [![Zsh](https://img.shields.io/badge/Zsh-5.9-green.svg)](https://www.zsh.org/) [![Kitty](https://img.shields.io/badge/Kitty-0.30.1-orange.svg)](https://sw.kovidgoyal.net/kitty/) [![Neovim](https://img.shields.io/badge/Neovim-0.10.0-green.svg)](https://neovim.io/) [![Cursor](https://img.shields.io/badge/Cursor-0.1.0-purple.svg)](https://cursor.sh/) | [![Node.js](https://img.shields.io/badge/Node.js-23.4.0-brightgreen.svg)](https://nodejs.org/) [![Python](https://img.shields.io/badge/Python-3.10.13-blue.svg)](https://www.python.org/) [![Rust](https://img.shields.io/badge/Rust-1.88.0-orange.svg)](https://www.rust-lang.org/) [![Elixir](https://img.shields.io/badge/Elixir-1.18.3-purple.svg)](https://elixir-lang.org/) [![Erlang](https://img.shields.io/badge/Erlang-26.2.4-red.svg)](https://www.erlang.org/) [![Lua](https://img.shields.io/badge/Lua-5.4.8-blue.svg)](https://www.lua.org/) | [![asdf](https://img.shields.io/badge/asdf-0.13.1-blue.svg)](https://asdf-vm.com/) [![direnv](https://img.shields.io/badge/direnv-2.32.3-yellow.svg)](https://direnv.net/) [![devenv](https://img.shields.io/badge/devenv-0.10.0-green.svg)](https://devenv.sh/) [![Nix](https://img.shields.io/badge/Nix-2.18.0-blue.svg)](https://nixos.org/) |
| **Project Templates** | [![web3](https://img.shields.io/badge/web3-⛓️-lightgrey.svg)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/templates) [![nextjs](https://img.shields.io/badge/Next.js-⚛️-black.svg)](https://nextjs.org/) [![react](https://img.shields.io/badge/React-⚛️-blue.svg)](https://reactjs.org/) [![rust](https://img.shields.io/badge/Rust-🦀-orange.svg)](https://www.rust-lang.org/) [![elixir](https://img.shields.io/badge/Elixir-💜-purple.svg)](https://elixir-lang.org/) [![node](https://img.shields.io/badge/Node.js-🟢-brightgreen.svg)](https://nodejs.org/) [![python](https://img.shields.io/badge/Python-🐍-blue.svg)](https://www.python.org/) [![go](https://img.shields.io/badge/Go-🔵-blue.svg)](https://golang.org/) | Full-stack blockchain, Modern React apps, CLI tools & services, Phoenix web apps, Node.js APIs, Python applications, Go services | Development Tools, Git, GitHub, Docker, Homebrew, Pre-commit, Performance Tools |

### 🌐 Web3 & Frameworks

| Web3 & Frameworks | Features & Workflow | Performance Metrics |
|-------------------|-------------------|-------------------|
| [![Ethereum](https://img.shields.io/badge/Ethereum-⚡-orange.svg)](https://ethereum.org/) [![Foundry](https://img.shields.io/badge/Foundry-🔨-orange.svg)](https://getfoundry.sh/) [![Solana](https://img.shields.io/badge/Solana-🟣-purple.svg)](https://solana.com/) [![Next.js](https://img.shields.io/badge/Next.js-⚛️-black.svg)](https://nextjs.org/) [![React](https://img.shields.io/badge/React-⚛️-blue.svg)](https://reactjs.org/) [![TypeScript](https://img.shields.io/badge/TypeScript-🔷-blue.svg)](https://www.typescriptlang.org/) [![Tailwind](https://img.shields.io/badge/Tailwind-🎨-cyan.svg)](https://tailwindcss.com/) | [![Lazy Loading](https://img.shields.io/badge/Lazy%20Loading-⚡-green.svg)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh/core) [![Templates](https://img.shields.io/badge/8%20Template%20Types-📋-blue.svg)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/templates) [![Monitor](https://img.shields.io/badge/Performance%20Monitor-📊-orange.svg)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/utils) [![Web3 Ready](https://img.shields.io/badge/Web3%20Ready-⛓️-purple.svg)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/templates) [![Speed](https://img.shields.io/badge/0.9s%20Saved%20per%20Shell-🚀-brightgreen.svg)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh/core) [![Memory](https://img.shields.io/badge/Memory%20Optimized-💾-blue.svg)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh/core) [![Auto-completion](https://img.shields.io/badge/Auto--completion-🎯-green.svg)](https://github.com/Hydepwns/dotfiles/tree/main/config/nvim) | [![Speed](https://img.shields.io/badge/0.9s%20Saved%20per%20Shell-🚀-brightgreen.svg)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh/core) [![Architecture](https://img.shields.io/badge/Modular%20Architecture-🧩-purple.svg)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh) [![Monitor](https://img.shields.io/badge/Performance%20Monitor-📊-orange.svg)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/utils) [![Auto-completion](https://img.shields.io/badge/Auto--completion-🎯-green.svg)](https://github.com/Hydepwns/dotfiles/tree/main/config/nvim) |

## 🔗 Neovim Plugins

### 🎨 UI & Theme

| Plugin | Description |
|--------|-------------|
| [![twilight.nvim](https://img.shields.io/badge/twilight.nvim-🌙-purple.svg)](https://github.com/folke/twilight.nvim) [![mini.hipatterns](https://img.shields.io/badge/mini.hipatterns-🎨-blue.svg)](https://github.com/echasnovski/mini.hipatterns) [![synthwave84.nvim](https://img.shields.io/badge/synthwave84.nvim-🌆-orange.svg)](https://github.com/rigellute/synthwave84.nvim) | Focus mode, pattern highlighting, retro theme |

### 💬 Comments & Completion

| Category | Plugins |
|----------|---------|
| **Comments** | [![Comment.nvim](https://img.shields.io/badge/Comment.nvim-💬-blue.svg)](https://github.com/numToStr/Comment.nvim) [![todo-comments.nvim](https://img.shields.io/badge/todo--comments.nvim-✅-green.svg)](https://github.com/folke/todo-comments.nvim) [![ts-context-commentstring](https://img.shields.io/badge/ts--context--commentstring-💬-blue.svg)](https://github.com/joosepalviste/nvim-ts-context-commentstring) |
| **Completion** | [![nvim-cmp](https://img.shields.io/badge/nvim--cmp-⚡-yellow.svg)](https://github.com/hrsh7th/nvim-cmp) [![LuaSnip](https://img.shields.io/badge/LuaSnip-📝-green.svg)](https://github.com/L3MON4D3/LuaSnip) [![friendly-snippets](https://img.shields.io/badge/friendly--snippets-🧩-purple.svg)](https://github.com/rafamadriz/friendly-snippets) |

### 📁 File Management & Git

| Category | Plugins |
|----------|---------|
| **File Explorer** | [![mini.files](https://img.shields.io/badge/mini.files-📂-blue.svg)](https://github.com/echasnovski/mini.files) [![nvim-tree.lua](https://img.shields.io/badge/nvim--tree.lua-🌳-green.svg)](https://github.com/nvim-tree/nvim-tree.lua) |
| **Git Integration** | [![gitsigns.nvim](https://img.shields.io/badge/gitsigns.nvim-🐙-orange.svg)](https://github.com/lewis6991/gitsigns.nvim) [![mini.diff](https://img.shields.io/badge/mini.diff-📊-blue.svg)](https://github.com/echasnovski/mini.diff) |

### 🛠️ LSP & Diagnostics

| Category | Plugins |
|----------|---------|
| **LSP** | [![nvim-lspconfig](https://img.shields.io/badge/nvim--lspconfig-🔧-blue.svg)](https://github.com/neovim/nvim-lspconfig) [![mason.nvim](https://img.shields.io/badge/mason.nvim-🛠️-orange.svg)](https://github.com/williamboman/mason.nvim) |
| **Diagnostics** | [![trouble.nvim](https://img.shields.io/badge/trouble.nvim-⚠️-yellow.svg)](https://github.com/folke/trouble.nvim) |

### 📝 Editing & Movement

| Category | Plugins |
|----------|---------|
| **Editing** | [![mini.pairs](https://img.shields.io/badge/mini.pairs-🔗-blue.svg)](https://github.com/echasnovski/mini.pairs) [![mini.surround](https://img.shields.io/badge/mini.surround-🔄-green.svg)](https://github.com/echasnovski/mini.surround) [![mini.ai](https://img.shields.io/badge/mini.ai-🤖-purple.svg)](https://github.com/echasnovski/mini.ai) |
| **Movement** | [![mini.move](https://img.shields.io/badge/mini.move-➡️-blue.svg)](https://github.com/echasnovski/mini.move) [![mini.operators](https://img.shields.io/badge/mini.operators-⚙️-grey.svg)](https://github.com/echasnovski/mini.operators) |

### 📊 Status & Testing

| Category | Plugins |
|----------|---------|
| **Status/Tabs** | [![mini.statusline](https://img.shields.io/badge/mini.statusline-📊-blue.svg)](https://github.com/echasnovski/mini.statusline) [![lualine.nvim](https://img.shields.io/badge/lualine.nvim-📊-green.svg)](https://github.com/nvim-lualine/lualine.nvim) [![mini.tabline](https://img.shields.io/badge/mini.tabline-📊-blue.svg)](https://github.com/echasnovski/mini.tabline) |
| **Testing** | [![neotest](https://img.shields.io/badge/neotest-🧪-green.svg)](https://github.com/nvim-neotest/neotest) [![neotest-*](https://img.shields.io/badge/neotest--*-🧪-green.svg)](https://github.com/nvim-neotest/neotest) |

### 🔍 Fuzzy Finder & Keybindings

| Category | Plugins |
|----------|---------|
| **Fuzzy Finder** | [![telescope.nvim](https://img.shields.io/badge/telescope.nvim-🔭-blue.svg)](https://github.com/nvim-telescope/telescope.nvim) [![mini.visits](https://img.shields.io/badge/mini.visits-📍-green.svg)](https://github.com/echasnovski/mini.visits) [![mini.extra](https://img.shields.io/badge/mini.extra-🔍-orange.svg)](https://github.com/echasnovski/mini.extra) |
| **Keybindings** | [![which-key.nvim](https://img.shields.io/badge/which--key.nvim-⌨️-purple.svg)](https://github.com/folke/which-key.nvim) [![flash.nvim](https://img.shields.io/badge/flash.nvim-⚡-yellow.svg)](https://github.com/folke/flash.nvim) |

### 📚 Note-taking & Utilities

| Category | Plugins |
|----------|---------|
| **Note-taking** | [![orgmode](https://img.shields.io/badge/orgmode-📖-green.svg)](https://github.com/nvim-orgmode/orgmode) [![neorg](https://img.shields.io/badge/neorg-📚-blue.svg)](https://github.com/nvim-neorg/neorg) |
| **Utilities** | [![mini.nvim](https://img.shields.io/badge/mini.nvim-🧩-purple.svg)](https://github.com/echasnovski/mini.nvim) [![noice.nvim](https://img.shields.io/badge/noice.nvim-🔊-orange.svg)](https://github.com/folke/noice.nvim) [![nvim-notify](https://img.shields.io/badge/nvim--notify-🔔-yellow.svg)](https://github.com/rcarriga/nvim-notify) [![dressing.nvim](https://img.shields.io/badge/dressing.nvim-🎛️-blue.svg)](https://github.com/stevearc/dressing.nvim) |

### 🎨 Fonts

| Plugin | Description |
|--------|-------------|
| [![mona.nvim](https://img.shields.io/badge/mona.nvim-🎨-purple.svg)](https://github.com/monaqa/mona.nvim) | Custom font support |

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
