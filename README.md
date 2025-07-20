# DROO's Dotfiles

[![Plugins](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugins?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Leader Key](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/leaderkey?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Plugin Manager](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugin-manager?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) - featuring modular tool loading, project templates, and development automation.

## 🚀 Configuration Overview

### 🛠️ Core Tools & Languages

| Category | Tools | Languages & Runtimes | Version Managers |
|----------|-------|---------------------|------------------|
| **Core Tools** | [![chezmoi](https://img.shields.io/badge/chezmoi-Latest-007ACC?style=for-the-badge&logo=chezmoi&logoColor=white)](https://www.chezmoi.io/) [![Zsh](https://img.shields.io/badge/Zsh-5.9-1A472A?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.zsh.org/) [![Kitty](https://img.shields.io/badge/Kitty-0.30.1-000000?style=for-the-badge&logo=kitty&logoColor=white)](https://sw.kovidgoyal.net/kitty/) [![Neovim](https://img.shields.io/badge/Neovim-0.10.0-57A143?style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io/) [![Cursor](https://img.shields.io/badge/Cursor-0.1.0-000000?style=for-the-badge&logo=cursor&logoColor=white)](https://cursor.sh/) | [![Node.js](https://img.shields.io/badge/Node.js-23.4.0-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/) [![Python](https://img.shields.io/badge/Python-3.10.13-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/) [![Rust](https://img.shields.io/badge/Rust-1.88.0-000000?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/) [![Elixir](https://img.shields.io/badge/Elixir-1.18.3-4B275F?style=for-the-badge&logo=elixir&logoColor=white)](https://elixir-lang.org/) [![Erlang](https://img.shields.io/badge/Erlang-26.2.4-A90533?style=for-the-badge&logo=erlang&logoColor=white)](https://www.erlang.org/) [![Lua](https://img.shields.io/badge/Lua-5.4.8-000080?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/) | [![asdf](https://img.shields.io/badge/asdf-0.13.1-FF6B6B?style=for-the-badge&logo=asdf&logoColor=white)](https://asdf-vm.com/) [![direnv](https://img.shields.io/badge/direnv-2.32.3-FFD93D?style=for-the-badge&logo=direnv&logoColor=black)](https://direnv.net/) [![devenv](https://img.shields.io/badge/devenv-0.10.0-5277C3?style=for-the-badge&logo=nixos&logoColor=white)](https://devenv.sh/) [![Nix](https://img.shields.io/badge/Nix-2.18.0-5277C3?style=for-the-badge&logo=nixos&logoColor=white)](https://nixos.org/) |
| **Project Templates** | [![web3](https://img.shields.io/badge/web3-⛓️-FF6B35?style=for-the-badge&logo=ethereum&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/templates) [![nextjs](https://img.shields.io/badge/Next.js-⚛️-000000?style=for-the-badge&logo=next.js&logoColor=white)](https://nextjs.org/) [![react](https://img.shields.io/badge/React-⚛️-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://reactjs.org/) [![rust](https://img.shields.io/badge/Rust-🦀-000000?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/) [![elixir](https://img.shields.io/badge/Elixir-💜-4B275F?style=for-the-badge&logo=elixir&logoColor=white)](https://elixir-lang.org/) [![node](https://img.shields.io/badge/Node.js-🟢-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/) [![python](https://img.shields.io/badge/Python-🐍-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/) [![go](https://img.shields.io/badge/Go-🔵-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://golang.org/) | Full-stack blockchain, Modern React apps, CLI tools & services, Phoenix web apps, Node.js APIs, Python applications, Go services | Development Tools, Git, GitHub, Docker, Homebrew, Pre-commit, Performance Tools |

### 🌐 Web3 & Frameworks

| Web3 & Frameworks | Features & Workflow | Performance Metrics |
|-------------------|-------------------|-------------------|
| [![Ethereum](https://img.shields.io/badge/Ethereum-⚡-3C3C3D?style=for-the-badge&logo=ethereum&logoColor=white)](https://ethereum.org/) [![Foundry](https://img.shields.io/badge/Foundry-🔨-FF6B35?style=for-the-badge&logo=foundry&logoColor=white)](https://getfoundry.sh/) [![Solana](https://img.shields.io/badge/Solana-🟣-9945FF?style=for-the-badge&logo=solana&logoColor=white)](https://solana.com/) [![Next.js](https://img.shields.io/badge/Next.js-⚛️-000000?style=for-the-badge&logo=next.js&logoColor=white)](https://nextjs.org/) [![React](https://img.shields.io/badge/React-⚛️-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://reactjs.org/) [![TypeScript](https://img.shields.io/badge/TypeScript-🔷-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/) [![Tailwind](https://img.shields.io/badge/Tailwind-🎨-06B6D4?style=for-the-badge&logo=tailwind-css&logoColor=white)](https://tailwindcss.com/) | [![Lazy Loading](https://img.shields.io/badge/Lazy%20Loading-⚡-00D4AA?style=for-the-badge&logo=speedtest&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh/core) [![Templates](https://img.shields.io/badge/8%20Template%20Types-📋-FF6B6B?style=for-the-badge&logo=template&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/templates) [![Monitor](https://img.shields.io/badge/Performance%20Monitor-📊-FF9A56?style=for-the-badge&logo=grafana&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/utils) [![Web3 Ready](https://img.shields.io/badge/Web3%20Ready-⛓️-9945FF?style=for-the-badge&logo=ethereum&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/templates) [![Speed](https://img.shields.io/badge/0.9s%20Saved%20per%20Shell-🚀-00D4AA?style=for-the-badge&logo=speedtest&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh/core) [![Memory](https://img.shields.io/badge/Memory%20Optimized-💾-4F46E5?style=for-the-badge&logo=memory&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh/core) [![Auto-completion](https://img.shields.io/badge/Auto--completion-🎯-10B981?style=for-the-badge&logo=autocomplete&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/config/nvim) | [![Speed](https://img.shields.io/badge/0.9s%20Saved%20per%20Shell-🚀-00D4AA?style=for-the-badge&logo=speedtest&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh/core) [![Architecture](https://img.shields.io/badge/Modular%20Architecture-🧩-8B5CF6?style=for-the-badge&logo=architecture&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/home/dot_zsh) [![Monitor](https://img.shields.io/badge/Performance%20Monitor-📊-FF9A56?style=for-the-badge&logo=grafana&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/scripts/utils) [![Auto-completion](https://img.shields.io/badge/Auto--completion-🎯-10B981?style=for-the-badge&logo=autocomplete&logoColor=white)](https://github.com/Hydepwns/dotfiles/tree/main/config/nvim) |

## 🔗 Neovim Plugins

### 🎨 UI & Theme

| Plugin | Description |
|--------|-------------|
| [![twilight.nvim](https://img.shields.io/badge/twilight.nvim-🌙-8B5CF6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/folke/twilight.nvim) [![mini.hipatterns](https://img.shields.io/badge/mini.hipatterns-🎨-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.hipatterns) [![synthwave84.nvim](https://img.shields.io/badge/synthwave84.nvim-🌆-FF6B35?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/rigellute/synthwave84.nvim) | Focus mode, pattern highlighting, retro theme |

### 💬 Comments & Completion

| Category | Plugins |
|----------|---------|
| **Comments** | [![Comment.nvim](https://img.shields.io/badge/Comment.nvim-💬-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/numToStr/Comment.nvim) [![todo-comments.nvim](https://img.shields.io/badge/todo--comments.nvim-✅-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/folke/todo-comments.nvim) [![ts-context-commentstring](https://img.shields.io/badge/ts--context--commentstring-💬-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/joosepalviste/nvim-ts-context-commentstring) |
| **Completion** | [![nvim-cmp](https://img.shields.io/badge/nvim--cmp-⚡-F59E0B?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/hrsh7th/nvim-cmp) [![LuaSnip](https://img.shields.io/badge/LuaSnip-📝-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/L3MON4D3/LuaSnip) [![friendly-snippets](https://img.shields.io/badge/friendly--snippets-🧩-8B5CF6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/rafamadriz/friendly-snippets) |

### 📁 File Management & Git

| Category | Plugins |
|----------|---------|
| **File Explorer** | [![mini.files](https://img.shields.io/badge/mini.files-📂-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.files) [![nvim-tree.lua](https://img.shields.io/badge/nvim--tree.lua-🌳-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/nvim-tree/nvim-tree.lua) |
| **Git Integration** | [![gitsigns.nvim](https://img.shields.io/badge/gitsigns.nvim-🐙-FF6B35?style=for-the-badge&logo=git&logoColor=white)](https://github.com/lewis6991/gitsigns.nvim) [![mini.diff](https://img.shields.io/badge/mini.diff-📊-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.diff) |

### 🛠️ LSP & Diagnostics

| Category | Plugins |
|----------|---------|
| **LSP** | [![nvim-lspconfig](https://img.shields.io/badge/nvim--lspconfig-🔧-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/neovim/nvim-lspconfig) [![mason.nvim](https://img.shields.io/badge/mason.nvim-🛠️-FF6B35?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/williamboman/mason.nvim) |
| **Diagnostics** | [![trouble.nvim](https://img.shields.io/badge/trouble.nvim-⚠️-F59E0B?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/folke/trouble.nvim) |

### 📝 Editing & Movement

| Category | Plugins |
|----------|---------|
| **Editing** | [![mini.pairs](https://img.shields.io/badge/mini.pairs-🔗-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.pairs) [![mini.surround](https://img.shields.io/badge/mini.surround-🔄-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.surround) [![mini.ai](https://img.shields.io/badge/mini.ai-🤖-8B5CF6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.ai) |
| **Movement** | [![mini.move](https://img.shields.io/badge/mini.move-➡️-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.move) [![mini.operators](https://img.shields.io/badge/mini.operators-⚙️-6B7280?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.operators) |

### 📊 Status & Testing

| Category | Plugins |
|----------|---------|
| **Status/Tabs** | [![mini.statusline](https://img.shields.io/badge/mini.statusline-📊-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.statusline) [![lualine.nvim](https://img.shields.io/badge/lualine.nvim-📊-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/nvim-lualine/lualine.nvim) [![mini.tabline](https://img.shields.io/badge/mini.tabline-📊-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.tabline) |
| **Testing** | [![neotest](https://img.shields.io/badge/neotest-🧪-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/nvim-neotest/neotest) [![neotest-*](https://img.shields.io/badge/neotest--*-🧪-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/nvim-neotest/neotest) |

### 🔍 Fuzzy Finder & Keybindings

| Category | Plugins |
|----------|---------|
| **Fuzzy Finder** | [![telescope.nvim](https://img.shields.io/badge/telescope.nvim-🔭-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/nvim-telescope/telescope.nvim) [![mini.visits](https://img.shields.io/badge/mini.visits-📍-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.visits) [![mini.extra](https://img.shields.io/badge/mini.extra-🔍-FF6B35?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.extra) |
| **Keybindings** | [![which-key.nvim](https://img.shields.io/badge/which--key.nvim-⌨️-8B5CF6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/folke/which-key.nvim) [![flash.nvim](https://img.shields.io/badge/flash.nvim-⚡-F59E0B?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/folke/flash.nvim) |

### 📚 Note-taking & Utilities

| Category | Plugins |
|----------|---------|
| **Note-taking** | [![orgmode](https://img.shields.io/badge/orgmode-📖-10B981?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/nvim-orgmode/orgmode) [![neorg](https://img.shields.io/badge/neorg-📚-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/nvim-neorg/neorg) |
| **Utilities** | [![mini.nvim](https://img.shields.io/badge/mini.nvim-🧩-8B5CF6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/echasnovski/mini.nvim) [![noice.nvim](https://img.shields.io/badge/noice.nvim-🔊-FF6B35?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/folke/noice.nvim) [![nvim-notify](https://img.shields.io/badge/nvim--notify-🔔-F59E0B?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/rcarriga/nvim-notify) [![dressing.nvim](https://img.shields.io/badge/dressing.nvim-🎛️-3B82F6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/stevearc/dressing.nvim) |

### 🎨 Fonts

| Plugin | Description |
|--------|-------------|
| [![mona.nvim](https://img.shields.io/badge/mona.nvim-🎨-8B5CF6?style=for-the-badge&logo=neovim&logoColor=white)](https://github.com/monaqa/mona.nvim) | Custom font support |

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
