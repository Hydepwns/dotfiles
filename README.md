# DROO's dotfiles

managed with [chezmoi](https://www.chezmoi.io/)

## Features

This dotfiles setup includes configuration for:

### Shell Configuration

- **Zsh** with Oh My Zsh configuration and customization
- **Zprofile** for login shell configuration
- Cross-platform support (macOS and Linux)
- Conditional loading based on available tools

### Development Tools

- **Git** configuration with work/personal separation
- **SSH** configuration with dynamic GitHub key fetching and 1Password integration
- **Node.js** via NVM (optional)
- **Ruby** via rbenv (optional)
- **Rust** toolchain
- **Python** via pipx
- **Elixir** with Mix and Kiex support (optional)
- **Lua** with LuaRocks and Luaenv support (optional)
- **direnv** for automatic environment loading (optional)
- **devenv** for Nix-based development environments (optional)
- **asdf** version manager (optional)
- **Nix** package manager (optional)

### macOS Specific

- **Homebrew** integration
- **MacPorts** support
- **iTerm2** shell integration
- **OrbStack** integration
- **Solana** CLI tools
- **Foundry** Ethereum development tools
- **Huff** smart contract language
- **LLVM** toolchain
- **PostgreSQL** tools

### Linux Specific

- **Kitty** terminal integration with enhanced SSH and image display

### Development Environment

- **VS Code** integration
- **Neovim** with LazyNvim and Monaspace font management
- **pnpm** package manager
- Global gitignore patterns
- Work-specific configurations

## Installation

### Prerequisites

1. Install chezmoi:

   ```bash
   # macOS
   brew install chezmoi
   
   # Linux
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $USER
   ```

2. Install required tools (chezmoi will prompt for these):
   - Git
   - Zsh (recommended)
   - Homebrew (macOS)
   - Various development tools as needed

3. Optional language installations:

   **Elixir:**

   ```bash
   # macOS
   brew install elixir
   
   # Or via asdf
   asdf plugin add elixir
   asdf install elixir latest
   asdf global elixir latest
   ```

      **Lua:**

   ```bash
   # macOS
   brew install lua
   
   # Or via asdf
   asdf plugin add lua
   asdf install lua latest
   asdf global lua latest
   ```

   **direnv:**

   ```bash
   # macOS
   brew install direnv
   
   # Or via asdf
   asdf plugin add direnv
   asdf install direnv latest
   asdf global direnv latest
   ```

   **devenv:**

   ```bash
   # Requires Nix to be installed first
   nix-env -iA nixpkgs.devenv
   
   # Or via Homebrew (macOS)
   brew install devenv
   ```

   **Neovim:**

   ```bash
   # macOS
   brew install neovim
   
   # Or via asdf
   asdf plugin add neovim
   asdf install neovim latest
   asdf global neovim latest
   ```

   ### Setup

1. Initialize chezmoi with this repository:

   ```bash
   chezmoi init --apply https://github.com/hydepwns/dotfiles.git
   ```

2. Chezmoi will prompt you for configuration:
   - Email address
   - Full name
   - Whether this is a work machine
   - Which tools you use (Nix, Oh My Zsh, asdf, NVM, rbenv, OrbStack, Elixir, Lua, direnv, devenv, Neovim)

3. Apply the configuration:

   ```bash
   chezmoi apply
   ```

## SSH Configuration

The dotfiles include a comprehensive SSH setup based on the [twpayne/dotfiles](https://github.com/twpayne/dotfiles) template with the following features:

### Features

- **Dynamic GitHub Key Fetching**: Automatically fetches your SSH public keys from GitHub
- **1Password Integration**: Secure storage of private SSH keys using 1Password CLI
- **Platform-Specific Optimizations**: macOS-specific configurations for keychain integration
- **Template-Based**: Uses chezmoi templates for easy customization and maintenance

### Setup

1. **GitHub Token Setup** (Required for dynamic key fetching):

   ```bash
   # Create a GitHub Personal Access Token
   # Go to: https://github.com/settings/tokens
   # Select 'read:user' scope for public key access
   
   # Add to your shell profile
   export GITHUB_TOKEN="your_token_here"
   ```

2. **1Password Integration** (Optional for private key storage):

   ```bash
   # Install 1Password CLI
   brew install --cask 1password-cli
   
   # Sign in to 1Password
   op signin
   
   # Create SSH key entries in 1Password with:
   # - Item name: "SSH Key"
   # - Username: "Personal"
   # - Fields: "public key" and "private key"
   ```

3. **Apply SSH Configuration**:

   ```bash
   chezmoi apply
   ```

### Files Generated

- `~/.ssh/config` - SSH client configuration with GitHub and custom host support
- `~/.ssh/authorized_keys` - Dynamically populated with your GitHub SSH keys
- `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` - Private/public keys (optional, requires 1Password CLI)

### Updating SSH Keys

When you add or remove SSH keys on GitHub, update your local configuration:

```bash
chezmoi execute-template --init --promptString personal=true < home/dot_ssh/authorized_keys.tmpl > ~/.ssh/authorized_keys
```

### Custom Host Configuration

Add your custom SSH hosts to `home/dot_ssh/config.tmpl`:

```bash
Host myserver
  HostName myserver.example.com
  User username
  ForwardAgent yes
```

## Oh My Zsh Configuration

Oh My Zsh is integrated into the main `.zshrc` configuration with the following features:

### Features

- **Integrated Configuration**: Oh My Zsh settings are part of the main shell configuration
- **Default Theme**: Uses the popular "robbyrussell" theme
- **Git Plugin**: Includes Git integration by default
- **Customizable**: Easy to modify themes, plugins, and settings

### Configuration Options

Edit `home/dot_zshrc` to customize Oh My Zsh:

- **Theme**: Change `ZSH_THEME="robbyrussell"` to your preferred theme
- **Plugins**: Modify the `plugins=(git)` line to add/remove plugins
- **Update Behavior**: Uncomment and configure auto-update settings
- **Performance**: Enable/disable features like auto-correction, completion dots

### Popular Plugins to Add

```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker kubectl)
```

### Custom Oh My Zsh Files

To add custom plugins, themes, or aliases, place them in:
- `~/.oh-my-zsh/custom/plugins/` - Custom plugins
- `~/.oh-my-zsh/custom/themes/` - Custom themes  
- `~/.oh-my-zsh/custom/` - Custom aliases and functions

## Configuration

### Personal vs Work Setup

The configuration automatically detects if you're on a work machine and:

- Sets appropriate Git credentials
- Configures work-specific aliases and paths
- Adds work-specific Git configurations

### Tool Detection

The setup conditionally loads configurations based on what tools you have installed:

- **Nix**: Adds Nix shell integration and paths
- **Oh My Zsh**: Loads Oh My Zsh with robbyrussell theme
- **asdf**: Initializes asdf version manager
- **NVM**: Sets up Node.js version management
- **rbenv**: Configures Ruby environment
- **OrbStack**: Adds OrbStack shell integration
- **Elixir**: Configures Elixir with Mix and Kiex support
- **Lua**: Configures Lua with LuaRocks and Luaenv support
- **direnv**: Sets up automatic environment loading from .envrc files
- **devenv**: Configures Nix-based development environment manager
- **Neovim**: Configures LazyNvim with Monaspace font management and comprehensive plugin setup

### Platform Support

- **macOS**: Full support with all macOS-specific tools and paths, including iTerm2 integration
- **Linux**: Full support with Linux-specific configurations, including Kitty terminal integration

## File Structure

```bash
.
├── .chezmoi.toml          # Chezmoi configuration and data
├── .chezmoiignore         # Files to ignore during apply
├── README.md              # This file
├── home/                  # Home directory dotfiles
│   ├── dot_gitconfig      # Git configuration
│   ├── dot_gitignore_global # Global gitignore patterns
│   ├── dot_zprofile       # Login shell configuration
│   ├── dot_zshrc          # Interactive shell configuration (includes Oh My Zsh)
│   ├── dot_tmux.conf      # Tmux configuration
│   ├── dot_czrc           # Commitizen configuration
│   └── dot_ssh/           # SSH configuration templates
│       ├── authorized_keys.tmpl # GitHub keys template
│       ├── config.tmpl    # SSH client config template
│       ├── id_rsa.pub.tmpl # Public key template (1Password)
│       └── private_id_rsa.tmpl # Private key template (1Password)
├── config/                # ~/.config directory
│   ├── nvim/              # Neovim configuration
│   │   ├── init.lua       # Main Neovim configuration
│   │   └── lua/           # Lua modules
│   │       ├── plugins/   # Plugin configurations
│   │       └── lazyvim/   # LazyNvim framework
│   ├── zed/               # Zed editor configuration
│   └── kitty/             # Kitty terminal configuration
├── zsh/                   # Zsh-specific configurations
│   ├── functions/         # Custom zsh functions
│   │   ├── _git.zsh       # Git-related functions
│   │   ├── _docker.zsh    # Docker-related functions
│   │   └── _dev.zsh       # Development utilities
│   ├── aliases/           # Zsh aliases
│   │   └── git.zsh        # Git aliases
│   └── themes/            # Custom themes (if any)
├── scripts/               # Utility scripts
│   ├── install/           # Installation scripts
│   │   └── install.sh     # Main installation script
│   ├── setup/             # Setup scripts
│   │   └── bootstrap.sh   # Initial setup script
│   └── utils/             # Utility functions
│       ├── platform.sh    # Platform detection
│       └── helpers.sh     # Helper functions
├── templates/             # Template files
│   ├── git/               # Git templates
│   └── shell/             # Shell templates
└── docs/                  # Documentation
    ├── installation.md    # Installation guide
    ├── configuration.md   # Configuration guide
    ├── customization.md   # Customization guide
    └── troubleshooting.md # Troubleshooting guide
```

## Customization

### Adding New Tools

1. Add a new prompt in `.chezmoi.toml`:

   ```toml
   {{- $newtool := promptBoolOnce . "newtool" "Do you use NewTool (y/n)" -}}
   ```

2. Add the data variable:

   ```toml
   [data]
       newtool = {{ $newtool }}
   ```

3. Add conditional configuration in the appropriate template file:

   ```bash
   {{- if .newtool -}}
   # NewTool configuration
   export PATH="$PATH:/path/to/newtool"
   {{- end -}}
   ```

### Work-Specific Configuration

Work-specific settings are automatically applied when you answer "yes" to the work machine prompt. These include:

- Git signing keys
- Work-specific Git aliases
- Work-specific environment variables
- Work-specific safe directories

### Neovim Configuration

The Neovim setup includes:

- **LazyNvim**: Modern plugin manager with lazy loading
- **synthwave84.nvim**: Retro synthwave colorscheme with neon glow effects
- **mona.nvim**: Monaspace font management and installation
- **SmoothCursor**: Beautiful cursor trails and animations
- **Comprehensive plugin suite**:
  - Telescope for fuzzy finding
  - Treesitter for syntax highlighting
  - LSP for language support
  - Mason for LSP/DAP/Linter management
  - Git integration with gitsigns
  - Testing framework with neotest
  - Debugging with DAP
  - Terminal integration
  - File explorer with nvim-tree
  - Status line with lualine
  - Cursor word highlighting
  - Argument highlighting
  - And many more productivity plugins

**Key bindings:**

- `<leader>tg` - Toggle synthwave glow effect
- `<leader>mf` - Font preview
- `<leader>mi` - Install Monaspace fonts
- `<leader>ms` - Font status
- `<leader>mh` - Font health check
- `<leader>ff` - Find files
- `<leader>fs` - Live grep
- `<leader>e` - File explorer
- `<leader>sm` - Open Mason
- `<leader>xx` - Show diagnostics
- `<leader>tt` - Run tests
- `<leader>gg` - Open lazygit

### Colorscheme Configuration

The setup includes the **synthwave84.nvim** colorscheme with the following features:

- **Retro synthwave aesthetic**: Neon colors and retro styling
- **Glow effects**: Customizable glow for functions, keywords, and error messages
- **Toggle functionality**: Use `<leader>tg` to toggle glow effects on/off
- **Optimized for coding**: Enhanced contrast and readability
- **Monaspace font compatibility**: Works perfectly with Monaspace fonts

**Glow configuration:**

- Error messages: Enhanced visibility
- Functions: Subtle glow highlighting
- Keywords: Neon keyword highlighting
- Types: Type2 glow effects
- Buffer targets: Current, visible, and inactive buffer highlighting

## Maintenance

### Updating Configuration

1. Edit the template files in this repository
2. Apply changes:

   ```bash
   chezmoi apply
   ```

### Adding New Files

1. Add the file to the repository
2. Update `.chezmoiignore` if needed
3. Apply:

   ```bash
   chezmoi apply
   ```

### Syncing Changes

To sync changes from your current system back to the repository:

```bash
chezmoi diff
chezmoi add <file>
chezmoi commit
```

## Troubleshooting

### Common Issues

1. **Template syntax errors**: Ensure all template tags use proper chezmoi syntax with `{{-` and `-}}`
2. **Path issues**: Check that the correct Homebrew prefix is being used for your architecture
3. **Tool not found**: Ensure the tool is installed before applying the configuration

### Debugging

- Use `chezmoi diff` to see what changes would be applied
- Use `chezmoi source-path` to see the template source
- Check the chezmoi logs for detailed error information

## License

This project is licensed under the MIT License - see the LICENSE file for details.
