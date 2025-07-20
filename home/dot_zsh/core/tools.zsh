# shellcheck disable=all
# Tool-specific configurations for DROO's dotfiles

# asdf configuration (primary version manager)
if command -v asdf &> /dev/null; then
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

# Rust configuration
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Node.js configuration (managed by asdf)
# No additional PATH needed as asdf handles this

# Elixir configuration (managed by asdf)
# No additional PATH needed as asdf handles this

# Erlang configuration (managed by asdf)
# No additional PATH needed as asdf handles this

# Lua configuration (managed by asdf)
# No additional PATH needed as asdf handles this

# direnv configuration
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

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
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
fi 