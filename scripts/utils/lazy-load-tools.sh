#!/bin/bash

# Enhanced Lazy Loading System for DROO's dotfiles
# This script provides comprehensive lazy loading for development tools

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/colors.sh"

# Performance tracking
LAZY_LOAD_DATA_FILE="$HOME/.cache/dotfiles-lazy-load.json"
LAZY_LOAD_STATS_FILE="$HOME/.cache/dotfiles-lazy-load-stats.json"

# Function to track lazy loading performance
track_lazy_load() {
    local tool_name="$1"
    local start_time="$2"
    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    # Save to data file
    local data_dir
    data_dir=$(dirname "$LAZY_LOAD_DATA_FILE")
    mkdir -p "$data_dir"

    local entry
    entry="{\"tool\":\"$tool_name\",\"duration\":$duration,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"

    if [[ -f "$LAZY_LOAD_DATA_FILE" ]]; then
        local existing_data
        existing_data=$(cat "$LAZY_LOAD_DATA_FILE" 2>/dev/null || echo "[]")
        echo "$existing_data" | jq ". += [$entry]" > "$LAZY_LOAD_DATA_FILE"
    else
        echo "[$entry]" > "$LAZY_LOAD_DATA_FILE"
    fi

    # Update stats
    update_lazy_load_stats "$tool_name" "$duration"

    # Log if loading takes more than 0.1 seconds
    if (( $(echo "$duration > 0.1" | bc -l 2>/dev/null || echo "0") )); then
        log_info "⏱️  Loaded $tool_name in ${duration}s"
    fi
}

# Function to update lazy loading statistics
update_lazy_load_stats() {
    local tool_name="$1"
    local duration="$2"

    local stats_file="$LAZY_LOAD_STATS_FILE"
    local data_dir
    data_dir=$(dirname "$stats_file")
    mkdir -p "$data_dir"

    # Load existing stats or create new
    if [[ -f "$stats_file" ]]; then
        local stats
        stats=$(cat "$stats_file" 2>/dev/null || echo "{}")
        
        # Update tool stats
        local tool_stats
        tool_stats=$(echo "$stats" | jq -r ".$tool_name // {}" 2>/dev/null || echo "{}")
        
        local count
        count=$(echo "$tool_stats" | jq -r ".count // 0" 2>/dev/null || echo "0")
        count=$((count + 1))
        
        local total
        total=$(echo "$tool_stats" | jq -r ".total // 0" 2>/dev/null || echo "0")
        total=$(echo "$total + $duration" | bc -l 2>/dev/null || echo "$total")
        
        local avg
        avg=$(echo "$total / $count" | bc -l 2>/dev/null || echo "0")
        
        local min
        min=$(echo "$tool_stats" | jq -r ".min // 999999" 2>/dev/null || echo "999999")
        if (( $(echo "$duration < $min" | bc -l 2>/dev/null || echo "0") )); then
            min="$duration"
        fi
        
        local max
        max=$(echo "$tool_stats" | jq -r ".max // 0" 2>/dev/null || echo "0")
        if (( $(echo "$duration > $max" | bc -l 2>/dev/null || echo "0") )); then
            max="$duration"
        fi
        
        # Update stats
        local new_tool_stats
        new_tool_stats="{\"count\":$count,\"total\":$total,\"avg\":$avg,\"min\":$min,\"max\":$max,\"last\":$duration}"
        
        echo "$stats" | jq ".$tool_name = $new_tool_stats" > "$stats_file"
    else
        local new_stats
        new_stats="{\"$tool_name\":{\"count\":1,\"total\":$duration,\"avg\":$duration,\"min\":$duration,\"max\":$duration,\"last\":$duration}}"
        echo "$new_stats" > "$stats_file"
    fi
}

# Enhanced lazy loading functions

# NVM lazy loading
lazy_load_nvm() {
    local start_time=$(date +%s.%N)
    
    if ! command -v nvm &> /dev/null; then
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            . "$NVM_DIR/nvm.sh"
            . "$NVM_DIR/bash_completion" 2>/dev/null
        fi
    fi
    
    track_lazy_load "nvm" "$start_time"
    nvm "$@"
}

# rbenv lazy loading
lazy_load_rbenv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v rbenv &> /dev/null; then
        export PATH="$HOME/.rbenv/shims:$PATH"
        eval "$(rbenv init -)"
    fi
    
    track_lazy_load "rbenv" "$start_time"
    rbenv "$@"
}

# pyenv lazy loading
lazy_load_pyenv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v pyenv &> /dev/null; then
        export PATH="$HOME/.pyenv/shims:$PATH"
        eval "$(pyenv init -)"
    fi
    
    track_lazy_load "pyenv" "$start_time"
    pyenv "$@"
}

# nodenv lazy loading
lazy_load_nodenv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v nodenv &> /dev/null; then
        export PATH="$HOME/.nodenv/shims:$PATH"
        eval "$(nodenv init -)"
    fi
    
    track_lazy_load "nodenv" "$start_time"
    nodenv "$@"
}

# goenv lazy loading
lazy_load_goenv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v goenv &> /dev/null; then
        export PATH="$HOME/.goenv/shims:$PATH"
        eval "$(goenv init -)"
    fi
    
    track_lazy_load "goenv" "$start_time"
    goenv "$@"
}

# asdf lazy loading
lazy_load_asdf() {
    local start_time=$(date +%s.%N)
    
    if ! command -v asdf &> /dev/null; then
        if [[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]]; then
            . "/opt/homebrew/opt/asdf/libexec/asdf.sh"
        elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
            . "$HOME/.asdf/asdf.sh"
        fi
    fi
    
    track_lazy_load "asdf" "$start_time"
    asdf "$@"
}

# direnv lazy loading
lazy_load_direnv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v direnv &> /dev/null; then
        eval "$(direnv hook zsh)"
    fi
    
    track_lazy_load "direnv" "$start_time"
    direnv "$@"
}

# devenv lazy loading
lazy_load_devenv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v devenv &> /dev/null; then
        if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
            . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
    fi
    
    track_lazy_load "devenv" "$start_time"
    devenv "$@"
}

# Ruby command lazy loading
lazy_load_ruby() {
    local start_time=$(date +%s.%N)
    
    if ! command -v ruby &> /dev/null || ! command -v gem &> /dev/null; then
        lazy_load_rbenv
    fi
    
    track_lazy_load "ruby" "$start_time"
    ruby "$@"
}

lazy_load_gem() {
    local start_time=$(date +%s.%N)
    
    if ! command -v gem &> /dev/null; then
        lazy_load_rbenv
    fi
    
    track_lazy_load "gem" "$start_time"
    gem "$@"
}

lazy_load_bundle() {
    local start_time=$(date +%s.%N)
    
    if ! command -v bundle &> /dev/null; then
        lazy_load_rbenv
    fi
    
    track_lazy_load "bundle" "$start_time"
    bundle "$@"
}

lazy_load_rake() {
    local start_time=$(date +%s.%N)
    
    if ! command -v rake &> /dev/null; then
        lazy_load_rbenv
    fi
    
    track_lazy_load "rake" "$start_time"
    rake "$@"
}

# Node.js command lazy loading
lazy_load_node() {
    local start_time=$(date +%s.%N)
    
    if ! command -v node &> /dev/null; then
        lazy_load_nvm
    fi
    
    track_lazy_load "node" "$start_time"
    node "$@"
}

lazy_load_npm() {
    local start_time=$(date +%s.%N)
    
    if ! command -v npm &> /dev/null; then
        lazy_load_nvm
    fi
    
    track_lazy_load "npm" "$start_time"
    npm "$@"
}

lazy_load_yarn() {
    local start_time=$(date +%s.%N)
    
    if ! command -v yarn &> /dev/null; then
        lazy_load_nvm
    fi
    
    track_lazy_load "yarn" "$start_time"
    yarn "$@"
}

# Python command lazy loading
lazy_load_python() {
    local start_time=$(date +%s.%N)
    
    if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
        lazy_load_pyenv
    fi
    
    track_lazy_load "python" "$start_time"
    python "$@"
}

lazy_load_pip() {
    local start_time=$(date +%s.%N)
    
    if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
        lazy_load_pyenv
    fi
    
    track_lazy_load "pip" "$start_time"
    pip "$@"
}

# Go command lazy loading
lazy_load_go() {
    local start_time=$(date +%s.%N)
    
    if ! command -v go &> /dev/null; then
        lazy_load_goenv
    fi
    
    track_lazy_load "go" "$start_time"
    go "$@"
}

# Rust command lazy loading
lazy_load_cargo() {
    local start_time=$(date +%s.%N)
    
    if ! command -v cargo &> /dev/null; then
        if [[ -s "$HOME/.cargo/env" ]]; then
            . "$HOME/.cargo/env"
        fi
    fi
    
    track_lazy_load "cargo" "$start_time"
    cargo "$@"
}

lazy_load_rustc() {
    local start_time=$(date +%s.%N)
    
    if ! command -v rustc &> /dev/null; then
        if [[ -s "$HOME/.cargo/env" ]]; then
            . "$HOME/.cargo/env"
        fi
    fi
    
    track_lazy_load "rustc" "$start_time"
    rustc "$@"
}

# Function to generate lazy loading configuration
generate_lazy_loading_config() {
    local config_file="$HOME/.zshrc.lazy"
    
    cat > "$config_file" << 'EOF'
# Enhanced Lazy Loading Configuration
# Generated by enhanced-lazy-loading.sh

# Performance tracking
LAZY_LOAD_DATA_FILE="$HOME/.cache/dotfiles-lazy-load.json"
LAZY_LOAD_STATS_FILE="$HOME/.cache/dotfiles-lazy-load-stats.json"

# Track lazy loading performance
track_lazy_load() {
    local tool_name="$1"
    local start_time="$2"
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
    
    # Save to data file
    local data_dir=$(dirname "$LAZY_LOAD_DATA_FILE")
    mkdir -p "$data_dir"
    
    local entry="{\"tool\":\"$tool_name\",\"duration\":$duration,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
    
    if [[ -f "$LAZY_LOAD_DATA_FILE" ]]; then
        local existing_data=$(cat "$LAZY_LOAD_DATA_FILE" 2>/dev/null || echo "[]")
        echo "$existing_data" | jq ". += [$entry]" > "$LAZY_LOAD_DATA_FILE"
    else
        echo "[$entry]" > "$LAZY_LOAD_DATA_FILE"
    fi
    
    # Log if loading takes more than 0.1 seconds
    if (( $(echo "$duration > 0.1" | bc -l 2>/dev/null || echo "0") )); then
        echo "⏱️  Loaded $tool_name in ${duration}s"
    fi
}

EOF

    # Add lazy loading functions based on available tools
    local tools=()
    
    if [[ -d "$HOME/.nvm" ]]; then
        tools+=("nvm")
        cat >> "$config_file" << 'EOF'

# NVM lazy loading
lazy_load_nvm() {
    local start_time=$(date +%s.%N)
    
    if ! command -v nvm &> /dev/null; then
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            . "$NVM_DIR/nvm.sh"
            . "$NVM_DIR/bash_completion" 2>/dev/null
        fi
    fi
    
    track_lazy_load "nvm" "$start_time"
    nvm "$@"
}

alias nvm='lazy_load_nvm'
alias node='lazy_load_node'
alias npm='lazy_load_npm'
alias yarn='lazy_load_yarn'

lazy_load_node() {
    local start_time=$(date +%s.%N)
    
    if ! command -v node &> /dev/null; then
        lazy_load_nvm
    fi
    
    track_lazy_load "node" "$start_time"
    node "$@"
}

lazy_load_npm() {
    local start_time=$(date +%s.%N)
    
    if ! command -v npm &> /dev/null; then
        lazy_load_nvm
    fi
    
    track_lazy_load "npm" "$start_time"
    npm "$@"
}

lazy_load_yarn() {
    local start_time=$(date +%s.%N)
    
    if ! command -v yarn &> /dev/null; then
        lazy_load_nvm
    fi
    
    track_lazy_load "yarn" "$start_time"
    yarn "$@"
}
EOF
    fi
    
    if [[ -d "$HOME/.rbenv" ]] || command -v rbenv &> /dev/null; then
        tools+=("rbenv")
        cat >> "$config_file" << 'EOF'

# rbenv lazy loading
lazy_load_rbenv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v rbenv &> /dev/null; then
        export PATH="$HOME/.rbenv/shims:$PATH"
        eval "$(rbenv init -)"
    fi
    
    track_lazy_load "rbenv" "$start_time"
    rbenv "$@"
}

alias rbenv='lazy_load_rbenv'
alias ruby='lazy_load_ruby'
alias gem='lazy_load_gem'
alias bundle='lazy_load_bundle'
alias rake='lazy_load_rake'

lazy_load_ruby() {
    local start_time=$(date +%s.%N)
    
    if ! command -v ruby &> /dev/null; then
        lazy_load_rbenv
    fi
    
    track_lazy_load "ruby" "$start_time"
    ruby "$@"
}

lazy_load_gem() {
    local start_time=$(date +%s.%N)
    
    if ! command -v gem &> /dev/null; then
        lazy_load_rbenv
    fi
    
    track_lazy_load "gem" "$start_time"
    gem "$@"
}

lazy_load_bundle() {
    local start_time=$(date +%s.%N)
    
    if ! command -v bundle &> /dev/null; then
        lazy_load_rbenv
    fi
    
    track_lazy_load "bundle" "$start_time"
    bundle "$@"
}

lazy_load_rake() {
    local start_time=$(date +%s.%N)
    
    if ! command -v rake &> /dev/null; then
        lazy_load_rbenv
    fi
    
    track_lazy_load "rake" "$start_time"
    rake "$@"
}
EOF
    fi
    
    if [[ -d "$HOME/.pyenv" ]] || command -v pyenv &> /dev/null; then
        tools+=("pyenv")
        cat >> "$config_file" << 'EOF'

# pyenv lazy loading
lazy_load_pyenv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v pyenv &> /dev/null; then
        export PATH="$HOME/.pyenv/shims:$PATH"
        eval "$(pyenv init -)"
    fi
    
    track_lazy_load "pyenv" "$start_time"
    pyenv "$@"
}

alias pyenv='lazy_load_pyenv'
alias python='lazy_load_python'
alias pip='lazy_load_pip'

lazy_load_python() {
    local start_time=$(date +%s.%N)
    
    if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
        lazy_load_pyenv
    fi
    
    track_lazy_load "python" "$start_time"
    python "$@"
}

lazy_load_pip() {
    local start_time=$(date +%s.%N)
    
    if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
        lazy_load_pyenv
    fi
    
    track_lazy_load "pip" "$start_time"
    pip "$@"
}
EOF
    fi
    
    if command -v asdf &> /dev/null || [[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]]; then
        tools+=("asdf")
        cat >> "$config_file" << 'EOF'

# asdf lazy loading
lazy_load_asdf() {
    local start_time=$(date +%s.%N)
    
    if ! command -v asdf &> /dev/null; then
        if [[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]]; then
            . "/opt/homebrew/opt/asdf/libexec/asdf.sh"
        elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
            . "$HOME/.asdf/asdf.sh"
        fi
    fi
    
    track_lazy_load "asdf" "$start_time"
    asdf "$@"
}

alias asdf='lazy_load_asdf'
EOF
    fi
    
    if command -v direnv &> /dev/null; then
        tools+=("direnv")
        cat >> "$config_file" << 'EOF'

# direnv lazy loading
lazy_load_direnv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v direnv &> /dev/null; then
        eval "$(direnv hook zsh)"
    fi
    
    track_lazy_load "direnv" "$start_time"
    direnv "$@"
}

alias direnv='lazy_load_direnv'
EOF
    fi
    
    if command -v devenv &> /dev/null || [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        tools+=("devenv")
        cat >> "$config_file" << 'EOF'

# devenv lazy loading
lazy_load_devenv() {
    local start_time=$(date +%s.%N)
    
    if ! command -v devenv &> /dev/null; then
        if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
            . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
    fi
    
    track_lazy_load "devenv" "$start_time"
    devenv "$@"
}

alias devenv='lazy_load_devenv'
EOF
    fi
    
    # Add performance reporting
    cat >> "$config_file" << 'EOF'

# Performance reporting
report_lazy_loading_performance() {
    if [[ -f "$LAZY_LOAD_STATS_FILE" ]]; then
        echo "🚀 Lazy Loading Performance Report:"
        echo "=================================="
        
        local stats
        stats=$(cat "$LAZY_LOAD_STATS_FILE" 2>/dev/null || echo "{}")
        
        echo "$stats" | jq -r 'to_entries[] | "\(.key): avg=\(.value.avg)s, count=\(.value.count), last=\(.value.last)s"' 2>/dev/null || echo "No performance data available"
    fi
}

# Add to precmd for automatic reporting
autoload -U add-zsh-hook
add-zsh-hook precmd report_lazy_loading_performance
EOF

    log_success "Enhanced lazy loading configuration generated: $config_file"
    log_info "Detected tools: ${tools[*]}"
    
    echo "To use this configuration, add the following to your .zshrc:"
    echo "source $config_file"
}

# Function to show lazy loading statistics
show_lazy_loading_stats() {
    if [[ ! -f "$LAZY_LOAD_STATS_FILE" ]]; then
        log_warn "No lazy loading statistics found"
        return 1
    fi
    
    log_info "Lazy Loading Statistics:"
    echo "=========================="
    
    local stats
    stats=$(cat "$LAZY_LOAD_STATS_FILE" 2>/dev/null || echo "{}")
    
    echo "$stats" | jq -r 'to_entries[] | "\(.key): avg=\(.value.avg)s, count=\(.value.count), last=\(.value.last)s"' 2>/dev/null || echo "No statistics available"
}

# Function to clean lazy loading data
clean_lazy_loading_data() {
    rm -f "$LAZY_LOAD_DATA_FILE" "$LAZY_LOAD_STATS_FILE"
    log_success "Lazy loading data cleaned"
}

# Main function
main() {
    case "${1:-}" in
        "generate")
            generate_lazy_loading_config
            ;;
        "stats")
            show_lazy_loading_stats
            ;;
        "clean")
            clean_lazy_loading_data
            ;;
        *)
            echo "Usage: $0 {generate|stats|clean}"
            echo ""
            echo "Commands:"
            echo "  generate  - Generate enhanced lazy loading configuration"
            echo "  stats     - Show lazy loading statistics"
            echo "  clean     - Clean lazy loading data"
            echo ""
            echo "This script provides enhanced lazy loading for development tools"
            echo "with performance tracking and analytics."
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 