# DROO's Brewfile - Declarative Package Management
# Install: brew bundle install
# Dump:    brew bundle dump --force
# Cleanup: brew bundle cleanup

# =============================================================================
# TAPS
# =============================================================================

tap "hashicorp/tap"
tap "homebrew/services"
tap "infisical/get-cli"
tap "kurtosis-tech/tap"

# =============================================================================
# CORE CLI TOOLS
# =============================================================================

brew "chezmoi"                 # Dotfile management
brew "mise"                    # Tool version manager (replaces asdf/nvm)
brew "curl"
brew "wget"
brew "git"
brew "shellcheck"              # Shell linting
brew "age"                     # File encryption (chezmoi secrets)
brew "starship"                # Cross-shell prompt
brew "tldr"                    # Simplified man pages

# =============================================================================
# LANGUAGES & RUNTIMES
# =============================================================================

# Elixir/Erlang (primary via mise, brew as fallback)
brew "elixir"
brew "erlang"

# Lua
brew "lua"
brew "lua-language-server"

# Go
brew "go"

# Python (brew for system python, pyenv for project versions)
brew "python@3.13"
brew "pyenv"

# Note: Node.js managed via mise
# Note: Rust managed via rustup

# =============================================================================
# CLOUD & INFRASTRUCTURE
# =============================================================================

# AWS
brew "awscli"

# Secrets
brew "infisical/get-cli/infisical"

# Virtualization
brew "qemu"
brew "libvirt", restart_service: :changed

# Containers (kurtosis for testing)
brew "kurtosis-tech/tap/kurtosis-cli"

# =============================================================================
# MONITORING & OBSERVABILITY
# =============================================================================

brew "grafana", restart_service: :changed
brew "prometheus"
brew "node_exporter"
brew "k6"                      # Load testing

# =============================================================================
# NETWORKING
# =============================================================================

brew "dnsmasq"
brew "unbound"
brew "mole"                    # SSH tunneling
brew "socat"

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

brew "neovim"
brew "autoconf"
brew "automake"
brew "libtool"
brew "pkgconf"

# Git utilities
brew "bfg"                     # Repo cleaner
brew "git-filter-repo"
brew "git-delta"               # Better git diffs
brew "gh"                      # GitHub CLI

# LLVM/Compilers
brew "zig"

# Ansible
brew "ansible-lint"

# IPFS
brew "kubo"

# =============================================================================
# CASKS - GUI APPLICATIONS
# =============================================================================

# Terminal
cask "ghostty"

# Editor
cask "zed"

# AI
cask "claude-code"

# Secrets & Auth
cask "1password"
cask "1password-cli"

# Networking
cask "tailscale-app"

# Containers
cask "docker"
cask "orbstack"

# Browsers
cask "brave-browser"
cask "google-chrome"
cask "firefox"

# Productivity
cask "hammerspoon"
cask "raycast"

# Communication
cask "discord"

# Other
cask "ngrok"

# Fonts
cask "font-monaspace"
cask "font-monaspace-nerd-font"

# =============================================================================
# OPTIONAL - Uncomment as needed
# =============================================================================

# Terminal alternatives (you have ghostty as primary)
# cask "iterm2"
# cask "kitty"

# Editor alternatives (you have zed as primary)
# cask "cursor"

# VS Code extensions (if using cursor/vscode)
# vscode "jakebecker.elixir-ls"
# vscode "golang.go"
# vscode "rust-lang.rust-analyzer"

# Terminal power tools
brew "fd"                      # Better find
brew "ripgrep"                 # Better grep
brew "bat"                     # Better cat
brew "eza"                     # Better ls
brew "fzf"                     # Fuzzy finder
brew "zoxide"                  # Smarter cd
brew "jq"                      # JSON processor
brew "yq"                      # YAML processor
brew "btop"                    # Modern system monitor (replaces htop)
brew "fastfetch"               # System info fetch (neofetch successor)
brew "tree"                    # Directory tree
brew "direnv"                  # Directory-based env vars
brew "yazi"                    # Terminal file manager
brew "ffmpeg"                  # Video thumbnails (yazi)
brew "sevenzip"                # Archive preview (yazi)
brew "poppler"                 # PDF preview (yazi)
brew "imagemagick"             # Image preview (yazi)

# Kubernetes
# brew "kubectl"
# brew "kubectx"
# brew "helm"
# brew "k9s"

# Terraform
# brew "hashicorp/tap/terraform"

# Database
# brew "postgresql@15"
# brew "redis"
# cask "tableplus"

# Streaming/Media
# cask "obs"
# cask "vlc"

# Games
# cask "love"                  # Love2D game engine (you have this)
