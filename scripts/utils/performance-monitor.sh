#!/usr/bin/env bash

# Use simple script initialization (no segfaults!)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/simple-init.sh"

# Performance monitoring script for DROO's dotfiles
# This script tracks and reports on shell performance metrics

# Simple utilities (no dependencies)
log_info() { echo -e "${BLUE:-}[INFO]${NC:-} $1"; }
log_success() { echo -e "${GREEN:-}[SUCCESS]${NC:-} $1"; }
log_error() { echo -e "${RED:-}[ERROR]${NC:-} $1" >&2; }
log_warning() { echo -e "${YELLOW:-}[WARNING]${NC:-} $1"; }

# Exit codes
EXIT_SUCCESS=0
EXIT_FAILURE=1

# Simple utility functions
file_exists() { test -f "$1"; }
dir_exists() { test -d "$1"; }
ensure_dir() { mkdir -p "$1"; }

# Performance data file
PERF_DATA_FILE="$HOME/.cache/dotfiles-performance.json"
PERF_HISTORY_FILE="$HOME/.cache/dotfiles-performance-history.json"
REALTIME_LOG_FILE="$HOME/.cache/dotfiles-realtime.log"

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
    if dir_exists "$HOME/.nvm"; then
        results+=("$(measure_command "nvm_load" "export NVM_DIR=\"$HOME/.nvm\"; . \"\$NVM_DIR/nvm.sh\"")")
    fi

    # Measure rbenv loading
    if command -v rbenv &> /dev/null || dir_exists "$HOME/.rbenv"; then
        results+=("$(measure_command "rbenv_load" "export PATH=\"$HOME/.rbenv/shims:\$PATH\"; eval \"\$(rbenv init -)\"")")
    fi

    # Measure asdf loading
    if command -v asdf &> /dev/null || dir_exists "/opt/homebrew/opt/asdf"; then
        results+=("$(measure_command "asdf_load" ". /opt/homebrew/opt/asdf/libexec/asdf.sh")")
    fi

    # Measure direnv loading
    if has_command direnv &> /dev/null; then
        results+=("$(measure_command "direnv_load" "eval \"\$(direnv hook zsh)\"")")
    fi

    # Measure pyenv loading
    if command -v pyenv &> /dev/null || dir_exists "$HOME/.pyenv"; then
        results+=("$(measure_command "pyenv_load" "export PATH=\"$HOME/.pyenv/shims:\$PATH\"; eval \"\$(pyenv init -)\"")")
    fi

    # Measure nodenv loading
    if command -v nodenv &> /dev/null || dir_exists "$HOME/.nodenv"; then
        results+=("$(measure_command "nodenv_load" "export PATH=\"$HOME/.nodenv/shims:\$PATH\"; eval \"\$(nodenv init -)\"")")
    fi

    # Measure goenv loading
    if command -v goenv &> /dev/null || dir_exists "$HOME/.goenv"; then
        results+=("$(measure_command "goenv_load" "export PATH=\"$HOME/.goenv/shims:\$PATH\"; eval \"\$(goenv init -)\"")")
    fi

    # Measure rustup loading
    if command -v rustup &> /dev/null || [[ -s "$HOME/.cargo/env" ]]; then
        results+=("$(measure_command "rustup_load" "source \"$HOME/.cargo/env\"")")
    fi

    # Output results as JSON array
    echo "[$(IFS=,; echo "${results[*]}")]"
}

# Function to measure system resources
measure_system_resources() {
    log_info "Measuring system resources..."

    local results=()

    # Memory usage
    local memory_info
    memory_info=$(free -m 2>/dev/null | grep Mem || echo "0 0 0")
    local total_mem
    total_mem=$(echo "$memory_info" | awk '{print $2}')
    local used_mem
    used_mem=$(echo "$memory_info" | awk '{print $3}')
    local mem_usage
    mem_usage=$(echo "scale=2; $used_mem / $total_mem * 100" | bc -l 2>/dev/null || echo "0")

    # CPU usage
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "0")

    # Disk usage
    local disk_usage
    disk_usage=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1 2>/dev/null || echo "0")

    # Shell process info
    local shell_pid=$$
    local shell_memory
    shell_memory=$(ps -o rss= -p $shell_pid 2>/dev/null || echo "0")
    local shell_cpu
    shell_cpu=$(ps -o %cpu= -p $shell_pid 2>/dev/null || echo "0")

    results+=("{\"type\":\"system_resources\",\"memory_usage\":$mem_usage,\"cpu_usage\":$cpu_usage,\"disk_usage\":$disk_usage,\"shell_memory_kb\":$shell_memory,\"shell_cpu_percent\":$shell_cpu,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}")

    echo "[$(IFS=,; echo "${results[*]}")]"
}

# Function to measure PATH performance
measure_path_performance() {
    log_info "Measuring PATH performance..."

    local results=()

    # Measure PATH length
    local path_length
    path_length=$(echo "$PATH" | tr ':' '\n' | wc -l)

    # Measure PATH search time
    local start_time
    start_time=$(date +%s.%N)
    has_command git &>/dev/null 2>&1
    local end_time
    end_time=$(date +%s.%N)
    local path_search_time
    path_search_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    # Count duplicate PATH entries
    local duplicate_count
    duplicate_count=$(echo "$PATH" | tr ':' '\n' | sort | uniq -d | wc -l)

    results+=("{\"type\":\"path_performance\",\"path_length\":$path_length,\"path_search_time\":$path_search_time,\"duplicate_entries\":$duplicate_count,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}")

    echo "[$(IFS=,; echo "${results[*]}")]"
}

# Function to measure function loading performance
measure_function_performance() {
    log_info "Measuring function loading performance..."

    local results=()

    # Measure autoload performance
    local start_time
    start_time=$(date +%s.%N)
    autoload -Uz compinit
    compinit -i
    local end_time
    end_time=$(date +%s.%N)
    local autoload_time
    autoload_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    # Count loaded functions
    local function_count
    function_count=$(typeset -f | wc -l)

    # Measure completion loading
    start_time=$(date +%s.%N)
    compdef _git git 2>/dev/null || true
    end_time=$(date +%s.%N)
    local completion_time
    completion_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    results+=("{\"type\":\"function_performance\",\"autoload_time\":$autoload_time,\"function_count\":$function_count,\"completion_time\":$completion_time,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}")

    echo "[$(IFS=,; echo "${results[*]}")]"
}

# Function to save performance data
save_performance_data() {
    local data="$1"
    local data_dir
    data_dir=$(dirname "$PERF_DATA_FILE")

    # Create directory if it doesn't exist
    mkdir -p "$data_dir"

    # Save current data
    echo "$data" > "$PERF_DATA_FILE"

    # Append to history
    if file_exists "$PERF_HISTORY_FILE"; then
        local history_data
        history_data=$(cat "$PERF_HISTORY_FILE" 2>/dev/null || echo "[]")
        local new_entry
        new_entry=$(echo "$data" | jq -c '. + {"session_id": "'$(date +%s)'"}')
        echo "$history_data" | jq ". += [$new_entry]" > "$PERF_HISTORY_FILE"
    else
        echo "[$(echo "$data" | jq -c '. + {"session_id": "'$(date +%s)'"}')]" > "$PERF_HISTORY_FILE"
    fi

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

    # Measure system resources
    local system_data
    system_data=$(measure_system_resources)

    # Measure PATH performance
    local path_data
    path_data=$(measure_path_performance)

    # Measure function performance
    local function_data
    function_data=$(measure_function_performance)

    # Combine data
    local combined_data="{\"shell_startup\":$shell_data,\"tool_loading\":$tool_data,\"system_resources\":$system_data,\"path_performance\":$path_data,\"function_performance\":$function_data}"

    # Save data
    save_performance_data "$combined_data"

    # Analyze results
    analyze_performance

    log_success "Performance test complete!"
}

# Function to show performance history
show_performance_history() {
    if [[ ! -f "$PERF_HISTORY_FILE" ]]; then
        log_warn "No performance history found"
        return 1
    fi

    log_info "Performance history from: $PERF_HISTORY_FILE"
    
    # Show last 5 entries
    local history_data
    history_data=$(cat "$PERF_HISTORY_FILE" 2>/dev/null || echo "[]")
    
    echo "$history_data" | jq -r '.[-5:] | .[] | "Session: \(.session_id) - Shell: \(.shell_startup.duration)s"' 2>/dev/null || echo "No readable history data"
}

# Function to start real-time monitoring
start_realtime_monitoring() {
    log_info "Starting real-time performance monitoring..."
    
    # Create log file
    touch "$REALTIME_LOG_FILE"
    
    # Start monitoring in background
    (
        while true; do
            local timestamp
            timestamp=$(date +%s.%N)
            local memory_usage
            memory_usage=$(ps -o rss= -p $$ 2>/dev/null || echo "0")
            local cpu_usage
            cpu_usage=$(ps -o %cpu= -p $$ 2>/dev/null || echo "0")
            
            echo "$timestamp|$memory_usage|$cpu_usage" >> "$REALTIME_LOG_FILE"
            sleep 5
        done
    ) &
    
    local monitor_pid=$!
    echo "$monitor_pid" > "$HOME/.cache/dotfiles-monitor.pid"
    
    log_success "Real-time monitoring started (PID: $monitor_pid)"
    log_info "Log file: $REALTIME_LOG_FILE"
    log_info "Stop with: $0 stop-monitoring"
}

# Function to stop real-time monitoring
stop_realtime_monitoring() {
    local pid_file="$HOME/.cache/dotfiles-monitor.pid"
    
    if file_exists "$pid_file"; then
        local monitor_pid
        monitor_pid=$(cat "$pid_file")
        
        if kill -0 "$monitor_pid" 2>/dev/null; then
            kill "$monitor_pid"
            rm -f "$pid_file"
            log_success "Real-time monitoring stopped"
        else
            log_warn "Monitor process not running"
            rm -f "$pid_file"
        fi
    else
        log_warn "No monitor PID file found"
    fi
}

# Function to show real-time monitoring data
show_realtime_data() {
    if [[ ! -f "$REALTIME_LOG_FILE" ]]; then
        log_warn "No real-time monitoring data found"
        return 1
    fi
    
    log_info "Real-time monitoring data:"
    
    # Show last 10 entries
    tail -10 "$REALTIME_LOG_FILE" | while read -r line; do
        local timestamp
        timestamp=$(echo "$line" | cut -d'|' -f1)
        local memory
        memory=$(echo "$line" | cut -d'|' -f2)
        local cpu
        cpu=$(echo "$line" | cut -d'|' -f3)
        
        local human_time
        human_time=$(date -d "@$timestamp" '+%H:%M:%S' 2>/dev/null || echo "$timestamp")
        
        echo "$human_time - Memory: ${memory}KB, CPU: ${cpu}%"
    done
}

# Function to generate performance report
generate_performance_report() {
    log_info "Generating performance report..."
    
    local report_file="$HOME/.cache/dotfiles-performance-report.md"
    
    cat > "$report_file" << 'EOF'
# Dotfiles Performance Report

Generated on: $(date)

## Summary

This report contains performance metrics for the dotfiles configuration.

## Shell Startup Performance

EOF

    if file_exists "$PERF_DATA_FILE"; then
        local data
        data=$(cat "$PERF_DATA_FILE")
        local shell_startup
        shell_startup=$(echo "$data" | grep -o '"duration":[0-9.]*' | head -1 | cut -d: -f2 || echo "0")
        
        echo "- **Shell Startup Time**: ${shell_startup}s" >> "$report_file"
        
        if (( $(echo "$shell_startup > 1.0" | bc -l 2>/dev/null || echo "0") )); then
            echo "- **Status**:  Slow (>1s)" >> "$report_file"
        elif (( $(echo "$shell_startup > 0.5" | bc -l 2>/dev/null || echo "0") )); then
            echo "- **Status**: [FAST] Moderate (0.5-1s)" >> "$report_file"
        else
            echo "- **Status**:  Fast (<0.5s)" >> "$report_file"
        fi
    else
        echo "- **Status**: No data available" >> "$report_file"
    fi

    cat >> "$report_file" << 'EOF'

## Tool Loading Performance

EOF

    if file_exists "$PERF_DATA_FILE"; then
        local data
        data=$(cat "$PERF_DATA_FILE")
        
        # Extract tool loading times
        local tools=("nvm" "rbenv" "asdf" "direnv" "pyenv" "nodenv" "goenv" "rustup")
        
        for tool in "${tools[@]}"; do
            local load_time
            load_time=$(echo "$data" | grep -o "\"command\":\"${tool}_load\",\"duration\":[0-9.]*" | cut -d: -f3 || echo "0")
            
            if (( $(echo "$load_time > 0" | bc -l 2>/dev/null || echo "0") )); then
                echo "- **${tool}**: ${load_time}s" >> "$report_file"
            fi
        done
    fi

    cat >> "$report_file" << 'EOF'

## Recommendations

1. **Lazy Loading**: Enable lazy loading for tools that take >0.1s to load
2. **PATH Optimization**: Remove duplicate PATH entries
3. **Function Optimization**: Use autoload for rarely used functions
4. **Regular Monitoring**: Run performance tests regularly

## Historical Data

EOF

    if file_exists "$PERF_HISTORY_FILE"; then
        local history_count
        history_count=$(cat "$PERF_HISTORY_FILE" | jq 'length' 2>/dev/null || echo "0")
        echo "- **Total Sessions**: $history_count" >> "$report_file"
    fi

    log_success "Performance report generated: $report_file"
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
        "start-monitoring")
            start_realtime_monitoring
            ;;
        "stop-monitoring")
            stop_realtime_monitoring
            ;;
        "realtime")
            show_realtime_data
            ;;
        "report")
            generate_performance_report
            ;;
        *)
            echo "Usage: $0 {measure|analyze|history|start-monitoring|stop-monitoring|realtime|report}"
            echo ""
            echo "Commands:"
            echo "  measure           - Run comprehensive performance test"
            echo "  analyze           - Analyze current performance data"
            echo "  history           - Show performance history"
            echo "  start-monitoring  - Start real-time monitoring"
            echo "  stop-monitoring   - Stop real-time monitoring"
            echo "  realtime          - Show real-time monitoring data"
            echo "  report            - Generate performance report"
            echo ""
            echo "Data files:"
            echo "  Current: $PERF_DATA_FILE"
            echo "  History: $PERF_HISTORY_FILE"
            echo "  Real-time: $REALTIME_LOG_FILE"
            exit $EXIT_FAILURE
            ;;
    esac
}

# Run main function
main "$@"
