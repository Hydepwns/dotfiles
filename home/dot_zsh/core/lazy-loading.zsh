# shellcheck disable=all
# Lazy loading system for version managers
# This file contains chezmoi template syntax which will be processed by chezmoi

# Performance tracking
PERF_START_TIME=$(date +%s.%N)

# Function to track loading time
track_loading() {
    local tool_name="$1"
    local start_time="$2"
    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
    local tool_name
    tool_name="$1"
    local start_time
    start_time="$2"
    local duration
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    # Store timing data for reporting
    export LAZY_LOAD_TIMES="${LAZY_LOAD_TIMES}${tool_name}:${duration}s "

    # Log if loading takes more than 0.1 seconds
    if (( $(echo "$duration > 0.1" | bc -l 2>/dev/null || echo "0") )); then
        echo "⏱️  Loaded $tool_name in ${duration}s"
    fi
}

# Lazy loading function for NVM
lazy_load_nvm() {
    local start_time=$(date +%s.%N)

    # Only load if not already loaded
    if ! command -v nvm &> /dev/null; then
        export NVM_DIR="{{ .chezmoi.homeDir }}/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            . "$NVM_DIR/nvm.sh"
            . "$NVM_DIR/bash_completion" 2>/dev/null
        fi
    fi

    track_loading "nvm" "$start_time"

    # Execute the original command
    nvm "$@"
}

# Lazy loading function for rbenv
lazy_load_rbenv() {
    local start_time=$(date +%s.%N)

    # Only load if not already loaded
    if ! command -v rbenv &> /dev/null; then
        export PATH="{{ .chezmoi.homeDir }}/.rbenv/shims:$PATH"
        eval "$(rbenv init -)"
    fi

    track_loading "rbenv" "$start_time"

    # Execute the original command
    rbenv "$@"
}

# Enhanced lazy loading for Ruby commands
lazy_load_ruby() {
    local start_time=$(date +%s.%N)
    local cmd="$1"
    shift

    # Only load if not already loaded
    if ! command -v rbenv &> /dev/null; then
        export PATH="{{ .chezmoi.homeDir }}/.rbenv/shims:$PATH"
        eval "$(rbenv init -)"
    fi

    track_loading "rbenv" "$start_time"

    # Execute the original command
    "$cmd" "$@"
}

# Lazy loading function for asdf
lazy_load_asdf() {
    local start_time=$(date +%s.%N)

    # Only load if not already loaded
    if ! command -v asdf &> /dev/null; then
        . {{ .brewPrefix }}/opt/asdf/libexec/asdf.sh
    fi

    track_loading "asdf" "$start_time"

    # Execute the original command
    asdf "$@"
}

# Lazy loading function for direnv
lazy_load_direnv() {
    local start_time=$(date +%s.%N)

    # Only load if not already loaded
    if ! command -v direnv &> /dev/null; then
        eval "$(direnv hook zsh)"
    fi

    track_loading "direnv" "$start_time"

    # Execute the original command
    direnv "$@"
}

# Lazy loading function for devenv
lazy_load_devenv() {
    local start_time=$(date +%s.%N)

    # Only load if not already loaded
    if ! command -v devenv &> /dev/null; then
        # Check if devenv is available via Nix
        if command -v nix &> /dev/null; then
            export PATH="/nix/var/nix/profiles/default/bin:$PATH"
            # Try to load devenv from Nix profile
            if nix profile list | grep -q devenv; then
                echo "Loading devenv from Nix profile..."
            fi
        fi
    fi

    track_loading "devenv" "$start_time"

    # Execute the original command
    devenv "$@"
}

# Setup lazy loading aliases
{{- if .nvm -}}
alias nvm='lazy_load_nvm'
{{- end -}}

{{- if .rbenv -}}
alias rbenv='lazy_load_rbenv'
alias ruby='lazy_load_ruby ruby'
alias gem='lazy_load_ruby gem'
alias bundle='lazy_load_ruby bundle'
alias rake='lazy_load_ruby rake'
{{- end -}}

{{- if .asdf -}}
alias asdf='lazy_load_asdf'
{{- end -}}

{{- if .direnv -}}
alias direnv='lazy_load_direnv'
{{- end -}}

{{- if .devenv -}}
alias devenv='lazy_load_devenv'
{{- end -}}

# Performance reporting function
report_performance() {
    if [[ -n "$LAZY_LOAD_TIMES" ]]; then
        echo "🚀 Lazy loading performance:"
        echo "$LAZY_LOAD_TIMES" | tr ' ' '\n' | grep -v '^$' | while read -r timing; do
            if [[ -n "$timing" ]]; then
                echo "  $timing"
            fi
        done
    fi

    # Report total shell startup time
    local end_time=$(date +%s.%N)
    local total_duration=$(echo "$end_time - $PERF_START_TIME" | bc -l 2>/dev/null || echo "0")
    echo "⏱️  Total shell startup time: ${total_duration}s"
}

# Add performance reporting to precmd (only once)
autoload -U add-zsh-hook
add-zsh-hook precmd report_performance

# Clear performance data after first report and disable future reports
add-zsh-hook precmd 'unset LAZY_LOAD_TIMES; unset PERF_START_TIME; add-zsh-hook -d precmd report_performance'
