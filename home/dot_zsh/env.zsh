# shellcheck disable=all
# Environment settings for DROO's dotfiles

# Automatically use the correct Node.js version with asdf
if command -v asdf &> /dev/null; then
    cd() {
        builtin cd "$@"
        if [ -f ".tool-versions" ]; then
            asdf install
        elif [ -f ".nvmrc" ]; then
            # Fallback for .nvmrc files - convert to asdf
            local node_version=$(cat .nvmrc)
            if asdf list nodejs | grep -q "$node_version"; then
                asdf local nodejs "$node_version"
            fi
        fi
    }
    # Initial setup for tool-versions directories
    if [ -d "$HOME/Documents/CODE/**/.tool-versions" ]; then
        asdf install
    fi
fi

# Git configuration
export GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-drew@axol.io}"
export GIT_COMMITTER_EMAIL="${GIT_COMMITTER_EMAIL:-drew@axol.io}"
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# Editor preferences
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"

# Language and locale settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Development environment
export NODE_ENV="${NODE_ENV:-development}"
export PYTHONPATH="${PYTHONPATH:-$HOME/.local/lib/python3.13/site-packages}"

# Terminal settings
export TERM="xterm-256color"
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

# History settings
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"

# Timeout settings
export TMOUT=0  # Disable auto-logout

# Development tool paths
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export GOPATH="$HOME/go"
export GOROOT="/opt/homebrew/opt/go/libexec"

# Add work-specific configs here if needed
