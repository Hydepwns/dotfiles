# shellcheck disable=all
# Tool-specific configurations for DROO's dotfiles

# Load lazy loading system
source "{{ .chezmoi.homeDir }}/.zsh/core/lazy-loading.zsh"

# Note: Version managers are now lazy-loaded for better performance
# They will be loaded only when first used

# devenv configuration
if command -v devenv &> /dev/null; then
    export DEVENV_DOTFILE=.devenv
    export DEVENV_PROFILE=.devenv/.profile
fi

# Nix-specific settings
if command -v nix &> /dev/null; then
    # Nix shell integration
    if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    fi
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
fi
