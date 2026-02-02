#!/bin/zsh
# Development workflow aliases
alias dev="cd ~/Documents/CODE"
alias work="cd ~/Documents/AXOL"
alias personal="cd ~/Documents/DROO"

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

# Elixir/Phoenix development
alias m="mix"
alias mf="mix format"
alias mt="mix test"
alias mtw="mix test --stale --listen-on-stdin"
alias mc="mix compile"
alias md="mix deps.get"
alias mdu="mix deps.update --all"
alias mdx="mix deps.clean --all && mix deps.get"
alias mr="mix run"
alias mi="iex -S mix"
alias mps="mix phx.server"
alias mph="iex -S mix phx.server"
alias mpr="mix phx.routes"
alias mec="mix ecto.create"
alias mem="mix ecto.migrate"
alias mer="mix ecto.rollback"
alias mes="mix ecto.setup"
alias med="mix ecto.drop"
alias meg="mix ecto.gen.migration"
alias mcr="mix credo --strict"
alias mdl="mix dialyzer"
alias mdc="mix docs"
alias mrl="mix release"
alias mclean="mix clean && mix deps.clean --all"

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
alias v="nvim"
alias nv="nvim"
alias z="zed"

# Network utilities
alias myip="curl -s https://ipinfo.io/ip"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"

# Development environment
alias reload="source ~/.zshrc"
alias dotfiles="cd ~/Documents/CODE/dotfiles"
alias backup-dotfiles="chezmoi diff && chezmoi add . && chezmoi commit"

# Tailscale
alias ts="tailscale"
alias tss="tailscale status"
alias tsup="tailscale up"
alias tsdown="tailscale down"
alias tsip="tailscale ip -4"
alias tsping="tailscale ping"
alias tsssh="tailscale ssh"
alias tsnet="tailscale netcheck"
alias tsexits="tailscale exit-node list"

# 1Password CLI
alias opl="op signin"
alias opw="op whoami"
alias opi="op item list"
alias opg="op item get"
alias opr="op read"
alias opv="op vault list"

# AWS CLI
alias awsw="aws sts get-caller-identity"
alias awsp="aws configure list-profiles"
alias awss="aws sso login"

# Infisical (backup secrets provider)
alias inf="infisical"
alias infl="infisical login"
alias infr="infisical run"
alias infs="infisical secrets"
alias infp="infisical export"

# Dotfiles dashboard and management
alias dash="~/.local/share/chezmoi/scripts/utils/dashboard.sh"
alias dashw="~/.local/share/chezmoi/scripts/utils/dashboard.sh --watch"
alias rotate-keys="~/.local/share/chezmoi/scripts/utils/secrets-rotation.sh rotate"
alias sync-keys="~/.local/share/chezmoi/scripts/utils/secrets-rotation.sh sync"
