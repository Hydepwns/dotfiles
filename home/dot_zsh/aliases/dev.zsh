#!/bin/zsh
# Development workflow aliases
alias dev="cd ~/Documents/CODE"
alias work="cd ~/Documents/CODE/work"
alias personal="cd ~/Documents/CODE/personal"

# Quick project navigation
alias proj="cd ~/Documents/CODE/$(ls ~/Documents/CODE | fzf)"

# Git workflow (moved to git.zsh)
# Use git aliases from home/dot_zsh/aliases/git.zsh

# Docker shortcuts
alias dc="docker-compose"
alias dex="docker exec -it"

# Development servers
alias dev-server="npm run dev"
alias test-watch="npm run test:watch"
alias build="npm run build"
alias start="npm start"

# Package managers
alias pn="pnpm"
alias pni="pnpm install"
alias pna="pnpm add"
alias pnr="pnpm remove"
alias pnd="pnpm dev"
alias pnb="pnpm build"

# Rust development
alias cb="cargo build"
alias cr="cargo run"
alias ct="cargo test"
alias cc="cargo check"
alias cf="cargo fmt"
alias ccl="cargo clippy"

# Python development
alias py="python3"
alias pip="pip3"
alias venv="python3 -m venv"
alias activate="source venv/bin/activate"

# Database
alias psql-dev="psql -h localhost -U postgres"
alias pg-start="brew services start postgresql"
alias pg-stop="brew services stop postgresql"

# Web3 development
alias forge-test="forge test"
alias forge-build="forge build"
alias solana-test="solana-test-validator"
alias anchor-test="anchor test"

# direnv shortcuts
alias da="direnv allow"
alias dr="direnv reload"
alias de="direnv edit"
alias ds="direnv status"

# devenv shortcuts
alias dv="devenv"
alias dvi="devenv init"
alias dvb="devenv build"
alias dvr="devenv run"
alias dvs="devenv shell"
alias dvc="devenv clean"

# Environment management
alias env-status="echo '=== direnv status ===' && direnv status && echo '=== devenv status ===' && devenv status 2>/dev/null || echo 'devenv not available'"

# System utilities
alias kill-port="kill -9 \$(lsof -ti:"
alias flush-dns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# Quick file operations
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ......="cd ../../../.."

# Editor shortcuts
alias v="vim"
alias nv="nvim"
alias z="zed"
alias c="code"

# Network utilities
alias myip="curl -s https://ipinfo.io/ip"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"

# Development environment
alias reload="source ~/.zshrc"
alias dotfiles="cd ~/Documents/CODE/dotfiles"
alias backup-dotfiles="chezmoi diff && chezmoi add . && chezmoi commit"
