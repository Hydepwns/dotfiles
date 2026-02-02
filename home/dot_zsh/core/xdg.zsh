# shellcheck disable=all
# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

# Core XDG directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Ensure directories exist
[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"
[[ -d "$XDG_STATE_HOME" ]] || mkdir -p "$XDG_STATE_HOME"
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"

# =============================================================================
# Tool-specific XDG paths
# =============================================================================

# Zsh
export ZDOTDIR="${ZDOTDIR:-$HOME}"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
[[ -d "${XDG_STATE_HOME}/zsh" ]] || mkdir -p "${XDG_STATE_HOME}/zsh"

# Less
export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
[[ -d "${XDG_STATE_HOME}/less" ]] || mkdir -p "${XDG_STATE_HOME}/less"

# Node.js / npm
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
export NODE_REPL_HISTORY="${XDG_STATE_HOME}/node/repl_history"
[[ -d "${XDG_STATE_HOME}/node" ]] || mkdir -p "${XDG_STATE_HOME}/node"

# Rust
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

# Go
export GOPATH="${XDG_DATA_HOME}/go"
export GOMODCACHE="${XDG_CACHE_HOME}/go/mod"

# Python
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"
export PYTHON_HISTORY="${XDG_STATE_HOME}/python/history"
export PYTHONPYCACHEPREFIX="${XDG_CACHE_HOME}/python"
export PIPX_HOME="${XDG_DATA_HOME}/pipx"

# Docker
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"

# AWS
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME}/aws/credentials"
export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"

# Kubernetes
export KUBECONFIG="${XDG_CONFIG_HOME}/kube/config"

# GNU utilities
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"

# Wget
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"
alias wget='wget --hsts-file="${XDG_STATE_HOME}/wget-hsts"'

# Starship
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
export STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"

# Bundler (Ruby)
export BUNDLE_USER_CONFIG="${XDG_CONFIG_HOME}/bundle"
export BUNDLE_USER_CACHE="${XDG_CACHE_HOME}/bundle"
export BUNDLE_USER_PLUGIN="${XDG_DATA_HOME}/bundle"

# asdf
export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdf/asdfrc"
export ASDF_DATA_DIR="${XDG_DATA_HOME}/asdf"

# Elixir/Erlang
export HEX_HOME="${XDG_DATA_HOME}/hex"
export MIX_HOME="${XDG_DATA_HOME}/mix"
export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 1024000"
export ELIXIR_ERL_OPTIONS="-elixir ansi_enabled true"

# Readline
export INPUTRC="${XDG_CONFIG_HOME}/readline/inputrc"

# =============================================================================
# Path updates for XDG-compliant tools
# =============================================================================

# Update PATH for XDG locations
export PATH="${CARGO_HOME}/bin:${GOPATH}/bin:${PATH}"
