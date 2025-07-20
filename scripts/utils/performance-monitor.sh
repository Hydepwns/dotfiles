#!/bin/bash

# Performance monitoring script for DROO's dotfiles
# This script tracks and reports on shell performance metrics

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/colors.sh"

# Performance data file
PERF_DATA_FILE="$HOME/.cache/dotfiles-performance.json"

# Function to measure command execution time
measure_command() {
    local command_name="$1"
    local command_to_run="$2"
    local start_time
    start_time=$(date +%s.%N)

    # Run the command and capture output
    eval "$command_to_run" >/dev/null 2>&1
    local exit_code
    exit_code=$?

    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    echo "{\"command\":\"$command_name\",\"duration\":$duration,\"exit_code\":$exit_code,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"

    return $exit_code
}

# Function to measure shell startup time
measure_shell_startup() {
    log_info "Measuring shell startup time..."

    # Create a temporary zsh script to measure startup
    local temp_script
    temp_script=$(mktemp)
    cat > "$temp_script" << 'EOF'
#!/bin/zsh
# Measure startup time
local START_TIME
START_TIME=$(date +%s.%N)

# Source the main zshrc
source ~/.zshrc

local END_TIME
END_TIME=$(date +%s.%N)
local DURATION
DURATION=$(echo "$END_TIME - $START_TIME" | bc -l 2>/dev/null || echo "0")
echo "{\"type\":\"shell_startup\",\"duration\":$DURATION,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
EOF

    chmod +x "$temp_script"

    # Run the measurement
    local result
    result=$(zsh -c "source $temp_script" 2>/dev/null || echo "{\"type\":\"shell_startup\",\"duration\":0,\"error\":\"failed\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}")

    # Clean up
    rm -f "$temp_script"

    echo "$result"
}

# Function to measure tool loading times
measure_tool_loading() {
    log_info "Measuring tool loading times..."

    local results=()

    # Measure NVM loading
    if [[ -d "$HOME/.nvm" ]]; then
        results+=("$(measure_command "nvm_load" "export NVM_DIR=\"$HOME/.nvm\"; . \"\$NVM_DIR/nvm.sh\"")")
    fi

    # Measure rbenv loading
    if command -v rbenv &> /dev/null || [[ -d "$HOME/.rbenv" ]]; then
        results+=("$(measure_command "rbenv_load" "export PATH=\"$HOME/.rbenv/shims:\$PATH\"; eval \"\$(rbenv init -)\"")")
    fi

    # Measure asdf loading
    if command -v asdf &> /dev/null || [[ -d "/opt/homebrew/opt/asdf" ]]; then
        results+=("$(measure_command "asdf_load" ". /opt/homebrew/opt/asdf/libexec/asdf.sh")")
    fi

    # Measure direnv loading
    if command -v direnv &> /dev/null; then
        results+=("$(measure_command "direnv_load" "eval \"\$(direnv hook zsh)\"")")
    fi

    # Output results as JSON array
    echo "[$(IFS=,; echo "${results[*]}")]"
}

# Function to save performance data
save_performance_data() {
    local data="$1"
    local data_dir
    data_dir=$(dirname "$PERF_DATA_FILE")

    # Create directory if it doesn't exist
    mkdir -p "$data_dir"

    # Save data
    echo "$data" > "$PERF_DATA_FILE"

    log_success "Performance data saved to $PERF_DATA_FILE"
}

# Function to load and analyze performance data
analyze_performance() {
    if [[ ! -f "$PERF_DATA_FILE" ]]; then
        log_warn "No performance data found. Run measurements first."
        return 1
    fi

    log_info "Analyzing performance data..."

    # Load data (simplified JSON parsing)
    local data
    data=$(cat "$PERF_DATA_FILE" 2>/dev/null || echo "{}")

    # Extract metrics (simplified)
    local shell_startup
    shell_startup=$(echo "$data" | grep -o '"duration":[0-9.]*' | head -1 | cut -d: -f2 || echo "0")
    local nvm_load
    nvm_load=$(echo "$data" | grep -o '"command":"nvm_load","duration":[0-9.]*' | cut -d: -f3 || echo "0")
    local rbenv_load
    rbenv_load=$(echo "$data" | grep -o '"command":"rbenv_load","duration":[0-9.]*' | cut -d: -f3 || echo "0")
    local asdf_load
    asdf_load=$(echo "$data" | grep -o '"command":"asdf_load","duration":[0-9.]*' | cut -d: -f3 || echo "0")
    local direnv_load
    direnv_load=$(echo "$data" | grep -o '"command":"direnv_load","duration":[0-9.]*' | cut -d: -f3 || echo "0")

    # Display analysis
    print_section "Performance Analysis"

    print_subsection "Shell Startup Time"
    if (( $(echo "$shell_startup > 0" | bc -l 2>/dev/null || echo "0") )); then
        print_status "INFO" "Shell startup: ${shell_startup}s"

        if (( $(echo "$shell_startup > 1.0" | bc -l 2>/dev/null || echo "0") )); then
            print_status "WARN" "Shell startup is slow (>1s)"
        elif (( $(echo "$shell_startup > 0.5" | bc -l 2>/dev/null || echo "0") )); then
            print_status "INFO" "Shell startup is moderate (0.5-1s)"
        else
            print_status "OK" "Shell startup is fast (<0.5s)"
        fi
    else
        print_status "WARN" "No shell startup data available"
    fi

    print_subsection "Tool Loading Times"
    if (( $(echo "$nvm_load > 0" | bc -l 2>/dev/null || echo "0") )); then
        print_status "INFO" "NVM loading: ${nvm_load}s"
    fi
    if (( $(echo "$rbenv_load > 0" | bc -l 2>/dev/null || echo "0") )); then
        print_status "INFO" "rbenv loading: ${rbenv_load}s"
    fi
    if (( $(echo "$asdf_load > 0" | bc -l 2>/dev/null || echo "0") )); then
        print_status "INFO" "asdf loading: ${asdf_load}s"
    fi
    if (( $(echo "$direnv_load > 0" | bc -l 2>/dev/null || echo "0") )); then
        print_status "INFO" "direnv loading: ${direnv_load}s"
    fi

    # Recommendations
    print_subsection "Recommendations"
    local total_tool_time
    total_tool_time=$(echo "$nvm_load + $rbenv_load + $asdf_load + $direnv_load" | bc -l 2>/dev/null || echo "0")

    if (( $(echo "$total_tool_time > 0.5" | bc -l 2>/dev/null || echo "0") )); then
        print_status "INFO" "Consider lazy loading for tools taking >0.1s each"
    fi

    if (( $(echo "$shell_startup > 1.0" | bc -l 2>/dev/null || echo "0") )); then
        print_status "INFO" "Consider optimizing shell configuration"
    fi
}

# Function to run comprehensive performance test
run_performance_test() {
    log_info "Running comprehensive performance test..."

    # Measure shell startup
    local shell_data
    shell_data=$(measure_shell_startup)

    # Measure tool loading
    local tool_data
    tool_data=$(measure_tool_loading)

    # Combine data
    local combined_data="{\"shell_startup\":$shell_data,\"tool_loading\":$tool_data}"

    # Save data
    save_performance_data "$combined_data"

    # Analyze results
    analyze_performance

    log_success "Performance test complete!"
}

# Function to show performance history
show_performance_history() {
    if [[ ! -f "$PERF_DATA_FILE" ]]; then
        log_warn "No performance data found"
        return 1
    fi

    log_info "Performance data from: $PERF_DATA_FILE"
    cat "$PERF_DATA_FILE" | jq '.' 2>/dev/null || cat "$PERF_DATA_FILE"
}

# Main function
main() {
    case "${1:-}" in
        "measure")
            run_performance_test
            ;;
        "analyze")
            analyze_performance
            ;;
        "history")
            show_performance_history
            ;;
        "clean")
            rm -f "$PERF_DATA_FILE"
            log_success "Performance data cleaned"
            ;;
        *)
            echo "Usage: $0 {measure|analyze|history|clean}"
            echo ""
            echo "Commands:"
            echo "  measure  - Run comprehensive performance test"
            echo "  analyze  - Analyze existing performance data"
            echo "  history  - Show performance data history"
            echo "  clean    - Clean performance data"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
