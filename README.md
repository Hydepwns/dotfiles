# DROO's Dotfiles

[![Plugins](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugins?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Leader Key](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/leaderkey?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![Plugin Manager](https://dotfyle.com/Hydepwns/dotfiles-config-nvim/badges/plugin-manager?style=flat)](https://dotfyle.com/Hydepwns/dotfiles-config-nvim)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/Hydepwns/dotfiles)

Cross-platform dotfiles managed with [chezmoi] - featuring modular tool loading, project templates, and development automation.

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [Config](#-config)
- [Optionals](#-optionals)
- [Templates](#-templates)
- [Performance](#-performance)
- [Core Tools](#-core-tools)
- [Neovim Plugins](#-neovim-plugins)
- [FAQ](#-faq)

## 🚀 Quick Start

```bash
# One-liner install (30 seconds)
curl -fsSL https://raw.githubusercontent.com/hydepwns/dotfiles/main/scripts/setup/quick-setup.sh | bash

# Alternative with chezmoi
brew install chezmoi && chezmoi init --apply https://github.com/hydepwns/dotfiles.git
```

## 🛠️ Usage

| Category | Command | Description |
|----------|---------|-------------|
| **🏠 Core** | `make install` | Install dotfiles |
| **🔄 Sync** | `make update` | Update from remote |
| **🏥 Health** | `make doctor` | System health check |
| **📡 Sync** | `make sync` | Sync local changes |

## ⚙️ Config

### 🎯 Initial Setup

The setup process will prompt for:

| Setting | Purpose | Example |
|---------|---------|---------|
| **📧 Email** | Git configuration | `user@example.com` |
| **👤 Username** | Git configuration | `Your Name` |
| **🛠️ Tool Preferences** | Nix, Oh My Zsh, asdf | `y/n` for each tool |
| **💻 Machine Type** | Personal (SSH keys) or Work | `personal` or `work` |

## 🤔 Optionals

### 🔑 SSH & GitHub Setup (Optional)

```bash
# Set GitHub token for SSH key fetching
export GITHUB_TOKEN="your_personal_access_token"

# Apply configuration with SSH keys
chezmoi apply

# Or use the setup script
./scripts/setup/setup-github-token.sh
```

## 🔧 Optionals

```bash
# Install additional tools
make install-optional

# Performance monitoring
make performance-monitor ACTION=measure

# Setup Cursor IDE
./scripts/setup/setup-cursor-simple.sh

# Edit specific configuration files
chezmoi edit ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.config/nvim/init.lua ~/.config/nvim/lua/plugins.lua

# Verify configuration integrity
chezmoi verify
chezmoi apply --source-path ~/.local/share/chezmoi
```

## 🛠️ Core Tools

| Category | Tools | Languages | Version Managers |
|----------|-------|-----------|------------------|
| **Core** | ![chezmoi-badge][] ![zsh-badge][] ![kitty-badge][] ![neovim-badge][] ![cursor-badge][] | ![node-badge][] ![python-badge][] ![rust-badge][] ![elixir-badge][] ![erlang-badge][] ![lua-badge][] | ![asdf-badge][] ![direnv-badge][] ![devenv-badge][] ![nix-badge][] |
| **Web3** | ![ethereum-badge][] ![foundry-badge][] ![solana-badge][] | ![nextjs-badge][] ![react-badge][] ![typescript-badge][] ![tailwind-badge][] | - |

## 🔗 Neovim Plugins

See [docs/nvim-plugins.md](docs/nvim-plugins.md) for a full categorized list and descriptions.

| Category | Count | Key Plugins |
|----------|-------|-------------|
| **🎨 UI & Theme** | 4 | twilight.nvim, mini.hipatterns, synthwave84.nvim, mona.nvim |
| **💬 Comments & Completion** | 6 | nvim-cmp, LuaSnip, Comment.nvim, todo-comments.nvim, ts-context-commentstring, friendly-snippets |
| **📁 File Management & Git** | 4 | mini.files, nvim-tree.lua, gitsigns.nvim, mini.diff |
| **🛠️ LSP & Diagnostics** | 4 | nvim-lspconfig, mason.nvim, trouble.nvim, conform.nvim |
| **📝 Editing & Movement** | 8 | mini.pairs, mini.surround, mini.ai, mini.move, mini.operators, mini.align, mini.trailspace, hlargs.nvim |
| **📊 Status & Testing** | 6 | mini.statusline, lualine.nvim, mini.tabline, neotest, neotest-*, mini.sessions |
| **🔍 Fuzzy Finder & Keybindings** | 5 | telescope.nvim, mini.visits, which-key.nvim, flash.nvim, mini.extra |
| **📚 Note-taking & Utilities** | 6 | orgmode, neorg, mini.nvim, noice.nvim, nvim-notify, dressing.nvim |
| **🎯 Treesitter & Animation** | 3 | nvim-treesitter, mini.animate, SmoothCursor.nvim |
| **🔧 Development** | 4 | neoconf.nvim, neodev.nvim, mini.indentscope, mini.cursorword |
| **Total** | 56 | |

## 📋 Templates

See [docs/templates.md](docs/templates.md) for detailed template information and usage examples.

| Template | Description | Features |
|----------|-------------|----------|
| ![web3-template-badge][] | Full-stack blockchain | Foundry, Hardhat, Web3.js, Ethers.js, Solana, Anchor |
| ![nextjs-template-badge][] | Modern React apps | TypeScript, Tailwind, ESLint, Prettier, NextAuth, Supabase |
| ![rust-template-badge][] | CLI tools & services | Cargo, Clippy, Testing, Documentation, Actix-web |
| ![elixir-template-badge][] | Phoenix web apps | Mix, ExUnit, Credo, Dialyzer, Ecto, Phoenix, Tailwind, LiveView |
| ![node-template-badge][] | Node.js APIs | Express, Jest, ESLint, TypeScript |
| ![python-template-badge][] | Python applications | Poetry, Pytest, Black, MyPy, FastAPI |
| ![go-template-badge][] | Go services | Modules, Testing, Linting, Protobuf |

### 🎨 Templates Usage

```bash
# Quick examples
make generate-template web3 my-project --web3-type both --with-tests --with-ci
make generate-template nextjs my-app --with-tests --with-ci --with-docs
make generate-template rust my-cli --with-docs --with-ci

# List all templates
make generate-template
```

## ⚡ Performance

Shell startup is up to **95% faster** with [lazy loading](https://github.com/Hydepwns/dotfiles/blob/main/scripts/utils/lazy-loading-benchmark.sh) and modular architecture. See [docs/performance.md](docs/performance.md) for detailed benchmarks.

| Feature | Improvement | Impact |
|---------|-------------|--------|
| **Lazy Loading** | 0.9s saved per shell | 95% faster startup |
| **Modular Architecture** | On-demand loading | Reduced memory usage |
| **Template System** | 8 project types | Faster project setup |

## ❓ FAQ

**Q: How do I customize the configuration?**
A: Edit files directly with `chezmoi edit ~/.zshrc` or modify templates in the source.

**Q: Can I use this on Windows?**
A: Currently optimized for macOS (use brew to install chezmoi) and Linux. Windows support is experimental (because I refuse to use it). Use devenv for windows.

**Q: How do I update my dotfiles?**
A: See [Usage](#-usage) section.

---

[chezmoi-badge]: https://img.shields.io/badge/chezmoi-dotfiles-blue?logo=github&labelColor=22272e&style=flat-square
[zsh-badge]: https://img.shields.io/badge/Zsh-shell-89e051?logo=zsh&logoColor=white&labelColor=22272e&style=flat-square
[kitty-badge]: https://img.shields.io/badge/Kitty-terminal-ffaa00?logo=kitty&logoColor=white&labelColor=22272e&style=flat-square
[neovim-badge]: https://img.shields.io/badge/Neovim-editor-57b6c2?logo=neovim&logoColor=white&labelColor=22272e&style=flat-square
[cursor-badge]: https://img.shields.io/badge/Cursor-IDE-4a90e2?logo=cursor&logoColor=white&labelColor=22272e&style=flat-square
[node-badge]: https://img.shields.io/badge/Node.js-runtime-339933?logo=node.js&logoColor=white&labelColor=22272e&style=flat-square
[python-badge]: https://img.shields.io/badge/Python-language-3776ab?logo=python&logoColor=white&labelColor=22272e&style=flat-square
[rust-badge]: https://img.shields.io/badge/Rust-language-000000?logo=rust&logoColor=white&labelColor=22272e&style=flat-square
[elixir-badge]: https://img.shields.io/badge/Elixir-language-6e4a7e?logo=elixir&logoColor=white&labelColor=22272e&style=flat-square
[erlang-badge]: https://img.shields.io/badge/Erlang-language-a90533?logo=erlang&logoColor=white&labelColor=22272e&style=flat-square
[lua-badge]: https://img.shields.io/badge/Lua-language-2c2d72?logo=lua&logoColor=white&labelColor=22272e&style=flat-square
[asdf-badge]: https://img.shields.io/badge/asdf-version--manager-faad4c?logo=gnubash&logoColor=white&labelColor=22272e&style=flat-square
[direnv-badge]: https://img.shields.io/badge/direnv-env-8cbb1f?logo=gnu&logoColor=white&labelColor=22272e&style=flat-square
[devenv-badge]: https://img.shields.io/badge/devenv-env-5e81ac?logo=nixos&logoColor=white&labelColor=22272e&style=flat-square
[nix-badge]: https://img.shields.io/badge/Nix-env-5277c3?logo=nixos&logoColor=white&labelColor=22272e&style=flat-square
[ethereum-badge]: https://img.shields.io/badge/Ethereum-blockchain-3c3c3d?logo=ethereum&logoColor=white&labelColor=22272e&style=flat-square
[foundry-badge]: https://img.shields.io/badge/Foundry-blockchain-ffb400?logo=foundry&logoColor=white&labelColor=22272e&style=flat-square
[solana-badge]: https://img.shields.io/badge/Solana-blockchain-00ffa3?logo=solana&logoColor=white&labelColor=22272e&style=flat-square
[nextjs-badge]: https://img.shields.io/badge/Next.js-framework-000000?logo=next.js&logoColor=white&labelColor=22272e&style=flat-square
[react-badge]: https://img.shields.io/badge/React-framework-61dafb?logo=react&logoColor=white&labelColor=22272e&style=flat-square
[typescript-badge]: https://img.shields.io/badge/TypeScript-language-3178c6?logo=typescript&logoColor=white&labelColor=22272e&style=flat-square
[tailwind-badge]: https://img.shields.io/badge/Tailwind-CSS-38bdf8?logo=tailwindcss&logoColor=white&labelColor=22272e&style=flat-square

[web3-template-badge]: https://img.shields.io/badge/web3-template-3c3c3d?logo=ethereum&logoColor=white&labelColor=22272e&style=flat-square
[nextjs-template-badge]: https://img.shields.io/badge/Next.js-template-000000?logo=next.js&logoColor=white&labelColor=22272e&style=flat-square
[rust-template-badge]: https://img.shields.io/badge/Rust-template-000000?logo=rust&logoColor=white&labelColor=22272e&style=flat-square
[elixir-template-badge]: https://img.shields.io/badge/Elixir-template-6e4a7e?logo=elixir&logoColor=white&labelColor=22272e&style=flat-square
[node-template-badge]: https://img.shields.io/badge/Node.js-template-339933?logo=node.js&logoColor=white&labelColor=22272e&style=flat-square
[python-template-badge]: https://img.shields.io/badge/Python-template-3776ab?logo=python&logoColor=white&labelColor=22272e&style=flat-square
[go-template-badge]: https://img.shields.io/badge/Go-template-00add8?logo=go&logoColor=white&labelColor=22272e&style=flat-square
