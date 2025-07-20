# shellcheck disable=all
# Environment settings for DROO's dotfiles

# DappSnap - Automatically use the correct Node.js version
if command -v nvm &> /dev/null; then
    cd() { builtin cd "$@" && if [ -f ".nvmrc" ]; then nvm use; elif [ -d "node_modules" ]; then nvm use 23.4.0; fi }
    # Initial setup for current directory
    if [ -d "$HOME/Documents/CODE/dappsnap/node_modules" ]; then nvm use 23.4.0; fi
fi

# Work-specific settings (can be customized)
export GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-test@example.com}"
export GIT_COMMITTER_EMAIL="${GIT_COMMITTER_EMAIL:-test@example.com}"
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# Add work-specific configs here if needed 