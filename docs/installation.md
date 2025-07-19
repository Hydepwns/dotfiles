# Installation Guide

This guide will help you install and set up your dotfiles on a new system.

## Installation Steps

### 1. Install Chezmoi

```bash
brew install chezmoi
```

#### Linux

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $USER
```

#### Manual Installation

```bash
curl -fsLS https://chezmoi.io/get | sh
```

### 2. Initialize Dotfiles

```bash
chezmoi init --apply https://github.com/hydepwns/dotfiles.git
```

### 3. Configure Your Setup

Chezmoi will prompt you for configuration options:

- **Email address** - For Git configuration
- **Full name** - For Git configuration
- **Work machine** - Whether this is a work machine (y/n)
- **Tool preferences** - Select your preferred tools

### 4. Apply Configuration

```bash
chezmoi apply
```

## Platform-Specific Setup

### macOS

1. **Install Homebrew** (if not already installed):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Xcode Command Line Tools**:

   ```bash
   xcode-select --install
   ```

3. **Install additional tools**:

   ```bash
   brew install git zsh chezmoi
   ```

### Linux

1. **Update package manager**:

   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt upgrade
   
   # CentOS/RHEL
   sudo yum update
   ```

2. **Install required packages**:

   ```bash
   # Ubuntu/Debian
   sudo apt install git zsh curl
   
   # CentOS/RHEL
   sudo yum install git zsh curl
   ```

## Post-Installation

### 1. Set Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

### 2. Restart Your Terminal

Close and reopen your terminal to ensure all changes take effect.

### 3. Install Language-Specific Tools

#### Node.js (via NVM)

```bash
nvm install --lts
nvm use --lts
```

#### Python (via pipx)

```bash
pipx install black flake8 mypy
```

#### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### Elixir

```bash
# macOS
brew install elixir

# Or via asdf
asdf plugin add elixir
asdf install elixir latest
asdf global elixir latest
```

#### Lua

```bash
# macOS
brew install lua

# Or via asdf
asdf plugin add lua
asdf install lua latest
asdf global lua latest
```

### 4. Install Neovim Plugins

If you chose to install Neovim, the plugins will be automatically installed on first launch.

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**
   - Ensure you have write permissions to your home directory
   - Use `sudo` if necessary for system-wide installations

2. **Chezmoi Template Errors**
   - Check that all required variables are set in `.chezmoi.toml`
   - Verify template syntax in configuration files

3. **Shell Not Found**
   - Ensure Zsh is installed: `which zsh`
   - Check if the path is correct in `/etc/shells`

4. **Git Configuration Issues**
   - Verify your email and name are correctly set
   - Check Git configuration: `git config --list`

### Getting Help

- Check the [troubleshooting guide](troubleshooting.md)
- Review the [configuration documentation](configuration.md)
- Open an issue on the GitHub repository

## Next Steps

After installation, you may want to:

1. **Customize your configuration** - See [customization guide](customization.md)
2. **Set up additional tools** - Install language-specific tools as needed
3. **Configure your editor** - Set up Neovim or your preferred editor
4. **Set up SSH keys** - For Git and remote access
5. **Configure your terminal** - Set up iTerm2 (macOS) or Kitty (Linux)

## Updating

To update your dotfiles:

```bash
chezmoi update
chezmoi apply
```

This will pull the latest changes and apply them to your system.
