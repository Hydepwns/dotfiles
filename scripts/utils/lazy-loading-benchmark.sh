#!/bin/bash

# Lazy Loading Performance Benchmark Script
# This script measures the performance impact of lazy loading vs eager loading
# and generates visualizations and reports

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/helpers.sh"
source "$SCRIPT_DIR/colors.sh"

# Configuration
BENCHMARK_DATA_DIR="$HOME/.cache/dotfiles-benchmark"
BENCHMARK_DATA_FILE="$BENCHMARK_DATA_DIR/lazy-loading-benchmark.json"
RESULTS_DIR="$BENCHMARK_DATA_DIR/results"
PLOTS_DIR="$BENCHMARK_DATA_DIR/plots"

# Tools to benchmark
TOOLS="nvm rbenv asdf direnv pyenv nodenv goenv rustup"

# Number of iterations for averaging
ITERATIONS=10

# Function to measure tool loading time
measure_tool_load() {
    local tool="$1"
    local load_type="$2"  # "eager" or "lazy"
    local start_time
    start_time=$(date +%s.%N)

    case "$tool" in
        "nvm")
            if [[ "$load_type" == "eager" ]]; then
                export NVM_DIR="$HOME/.nvm"
                . "$NVM_DIR/nvm.sh" >/dev/null 2>&1
            else
                # Simulate lazy loading - just check if available
                [[ -s "$HOME/.nvm/nvm.sh" ]]
            fi
            ;;
        "rbenv")
            if [[ "$load_type" == "eager" ]]; then
                export PATH="$HOME/.rbenv/shims:$PATH"
                eval "$(rbenv init -)" >/dev/null 2>&1
            else
                command -v rbenv >/dev/null 2>&1
            fi
            ;;
        "asdf")
            if [[ "$load_type" == "eager" ]]; then
                . /opt/homebrew/opt/asdf/libexec/asdf.sh >/dev/null 2>&1
            else
                command -v asdf >/dev/null 2>&1
            fi
            ;;
        "direnv")
            if [[ "$load_type" == "eager" ]]; then
                if command -v direnv &> /dev/null; then
                    eval "$(direnv hook zsh)" >/dev/null 2>&1
                fi
            else
                command -v direnv >/dev/null 2>&1
            fi
            ;;
        "pyenv")
            if [[ "$load_type" == "eager" ]]; then
                export PATH="$HOME/.pyenv/shims:$PATH"
                eval "$(pyenv init -)" >/dev/null 2>&1
            else
                command -v pyenv >/dev/null 2>&1
            fi
            ;;
        "nodenv")
            if [[ "$load_type" == "eager" ]]; then
                export PATH="$HOME/.nodenv/shims:$PATH"
                eval "$(nodenv init -)" >/dev/null 2>&1
            else
                command -v nodenv >/dev/null 2>&1
            fi
            ;;
        "goenv")
            if [[ "$load_type" == "eager" ]]; then
                export PATH="$HOME/.goenv/shims:$PATH"
                eval "$(goenv init -)" >/dev/null 2>&1
            else
                command -v goenv >/dev/null 2>&1
            fi
            ;;
        "rustup")
            if [[ "$load_type" == "eager" ]]; then
                . "$HOME/.cargo/env" >/dev/null 2>&1
            else
                command -v rustup >/dev/null 2>&1
            fi
            ;;
    esac

    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    # Ensure we always return a valid number
    if [[ -z "$duration" ]] || [[ "$duration" == "null" ]] || [[ "$duration" == "0" ]]; then
        duration="0"
    fi

    # Ensure decimal numbers start with 0
    if [[ "$duration" =~ ^\.[0-9]+$ ]]; then
        duration="0$duration"
    fi

    echo "$duration"
}

# Function to run benchmark for a single tool
benchmark_tool() {
    local tool="$1"
    local results=()

    # Run eager loading measurements
    for ((i=1; i<=ITERATIONS; i++)); do
        local eager_time
        eager_time=$(measure_tool_load "$tool" "eager")
        results+=("{\"tool\":\"$tool\",\"type\":\"eager\",\"iteration\":$i,\"duration\":$eager_time}")
    done

    # Run lazy loading measurements
    for ((i=1; i<=ITERATIONS; i++)); do
        local lazy_time
        lazy_time=$(measure_tool_load "$tool" "lazy")
        results+=("{\"tool\":\"$tool\",\"type\":\"lazy\",\"iteration\":$i,\"duration\":$lazy_time}")
    done

    # Output results as JSON array
    echo "[$(IFS=,; echo "${results[*]}")]"
}

# Function to calculate statistics
calculate_stats() {
    local data="$1"
    local tool="$2"
    local load_type="$3"

    # Extract durations for this tool and type
    local durations
    durations=$(echo "$data" | jq -r ".[] | select(.tool == \"$tool\" and .type == \"$load_type\") | .duration" 2>/dev/null || echo "0")

    # Calculate statistics
    local count=0
    local sum=0
    local min=999999
    local max=0

    while IFS= read -r duration; do
        if [[ -n "$duration" ]] && [[ "$duration" != "null" ]]; then
            count=$((count + 1))
            sum=$(echo "$sum + $duration" | bc -l 2>/dev/null || echo "$sum")

            if (( $(echo "$duration < $min" | bc -l 2>/dev/null || echo "0") )); then
                min="$duration"
            fi

            if (( $(echo "$duration > $max" | bc -l 2>/dev/null || echo "0") )); then
                max="$duration"
            fi
        fi
    done <<< "$durations"

    local avg=0
    if [[ $count -gt 0 ]]; then
        avg=$(echo "$sum / $count" | bc -l 2>/dev/null || echo "0")
    fi

    echo "{\"tool\":\"$tool\",\"type\":\"$load_type\",\"count\":$count,\"min\":$min,\"max\":$max,\"avg\":$avg,\"sum\":$sum}"
}

# Function to generate performance matrix
generate_performance_matrix() {
    local data="$1"
    local matrix_file="$RESULTS_DIR/performance-matrix.md"

    mkdir -p "$RESULTS_DIR"

    cat > "$matrix_file" << 'EOF'
# Lazy Loading Performance Matrix

## Tool Loading Performance Comparison

| Tool | Eager Loading (avg) | Lazy Loading (avg) | Improvement | Status |
|------|-------------------|-------------------|-------------|---------|
EOF

    local total_eager=0
    local total_lazy=0

    for tool in $TOOLS; do
        local eager_stats
        eager_stats=$(calculate_stats "$data" "$tool" "eager")
        local lazy_stats
        lazy_stats=$(calculate_stats "$data" "$tool" "lazy")

        local eager_avg
        eager_avg=$(echo "$eager_stats" | jq -r '.avg' 2>/dev/null || echo "0")
        local lazy_avg
        lazy_avg=$(echo "$lazy_stats" | jq -r '.avg' 2>/dev/null || echo "0")

        total_eager=$(echo "$total_eager + $eager_avg" | bc -l 2>/dev/null || echo "$total_eager")
        total_lazy=$(echo "$total_lazy + $lazy_avg" | bc -l 2>/dev/null || echo "$total_lazy")

        local improvement=0
        local status="🟢"

        if (( $(echo "$eager_avg > 0" | bc -l 2>/dev/null || echo "0") )); then
            improvement=$(echo "($eager_avg - $lazy_avg) / $eager_avg * 100" | bc -l 2>/dev/null || echo "0")

            if (( $(echo "$improvement > 50" | bc -l 2>/dev/null || echo "0") )); then
                status="🟢"
            elif (( $(echo "$improvement > 25" | bc -l 2>/dev/null || echo "0") )); then
                status="🟡"
            else
                status="🔴"
            fi
        fi

        printf "| %s | %.3fs | %.3fs | %.1f%% | %s |\n" \
            "$tool" "$eager_avg" "$lazy_avg" "$improvement" "$status" >> "$matrix_file"
    done

    # Add totals row
    local total_improvement=0
    if (( $(echo "$total_eager > 0" | bc -l 2>/dev/null || echo "0") )); then
        total_improvement=$(echo "($total_eager - $total_lazy) / $total_eager * 100" | bc -l 2>/dev/null || echo "0")
    fi

    printf "\n| **TOTAL** | **%.3fs** | **%.3fs** | **%.1f%%** | **📊** |\n" \
        "$total_eager" "$total_lazy" "$total_improvement" >> "$matrix_file"

    cat >> "$matrix_file" << 'EOF'

## Performance Summary

- **Total Eager Loading Time**: $(printf "%.3fs" $total_eager)
- **Total Lazy Loading Time**: $(printf "%.3fs" $total_lazy)
- **Overall Improvement**: $(printf "%.1f%%" $total_improvement)
- **Time Saved**: $(printf "%.3fs" $(echo "$total_eager - $total_lazy" | bc -l 2>/dev/null || echo "0"))

## Recommendations

- 🟢 **Excellent**: >50% improvement - Keep lazy loading
- 🟡 **Good**: 25-50% improvement - Consider optimization
- 🔴 **Poor**: <25% improvement - May not be worth lazy loading

---
*Generated on $(date)*
EOF

    log_success "Performance matrix generated: $matrix_file"
}

# Function to generate Python visualization script
generate_visualization_script() {
    local data="$1"
    local script_file="$PLOTS_DIR/generate_plots.py"

    mkdir -p "$PLOTS_DIR"

    cat > "$script_file" << 'EOF'
#!/usr/bin/env python3
"""
Generate performance visualization plots for lazy loading benchmark
"""

import json
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from pathlib import Path
import sys

def load_data(data_file):
    """Load benchmark data from JSON file"""
    try:
        with open(data_file, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading data: {e}")
        return []

def create_comparison_chart(data, output_dir):
    """Create bar chart comparing eager vs lazy loading"""
    tools = {}

    # Group data by tool
    for entry in data:
        tool = entry.get('tool', '')
        load_type = entry.get('type', '')
        duration = entry.get('duration', 0)

        if tool not in tools:
            tools[tool] = {'eager': [], 'lazy': []}

        if load_type in ['eager', 'lazy']:
            tools[tool][load_type].append(duration)

    # Calculate averages
    tool_names = []
    eager_avgs = []
    lazy_avgs = []

    for tool, measurements in tools.items():
        if measurements['eager'] and measurements['lazy']:
            tool_names.append(tool)
            eager_avgs.append(np.mean(measurements['eager']))
            lazy_avgs.append(np.mean(measurements['lazy']))

    if not tool_names:
        print("No data to plot")
        return

    # Create the plot
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))

    # Bar chart
    x = np.arange(len(tool_names))
    width = 0.35

    bars1 = ax1.bar(x - width/2, eager_avgs, width, label='Eager Loading', color='#ff6b6b', alpha=0.8)
    bars2 = ax1.bar(x + width/2, lazy_avgs, width, label='Lazy Loading', color='#4ecdc4', alpha=0.8)

    ax1.set_xlabel('Tools')
    ax1.set_ylabel('Loading Time (seconds)')
    ax1.set_title('Lazy vs Eager Loading Performance Comparison')
    ax1.set_xticks(x)
    ax1.set_xticklabels(tool_names, rotation=45)
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Add value labels on bars
    for bar in bars1:
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.3f}s', ha='center', va='bottom', fontsize=8)

    for bar in bars2:
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.3f}s', ha='center', va='bottom', fontsize=8)

    # Improvement percentage chart
    improvements = []
    for eager, lazy in zip(eager_avgs, lazy_avgs):
        if eager > 0:
            improvement = ((eager - lazy) / eager) * 100
        else:
            improvement = 0
        improvements.append(improvement)

    bars3 = ax2.bar(tool_names, improvements, color='#45b7d1', alpha=0.8)
    ax2.set_xlabel('Tools')
    ax2.set_ylabel('Improvement (%)')
    ax2.set_title('Performance Improvement with Lazy Loading')
    ax2.set_xticklabels(tool_names, rotation=45)
    ax2.grid(True, alpha=0.3)

    # Add value labels
    for bar in bars3:
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.1f}%', ha='center', va='bottom')

    # Add horizontal line at 0%
    ax2.axhline(y=0, color='black', linestyle='-', alpha=0.3)

    plt.tight_layout()
    plt.savefig(f'{output_dir}/lazy-loading-performance.png', dpi=300, bbox_inches='tight')
    plt.savefig(f'{output_dir}/lazy-loading-performance.svg', bbox_inches='tight')
    print(f"Charts saved to {output_dir}/")

    # Create summary statistics
    total_eager = sum(eager_avgs)
    total_lazy = sum(lazy_avgs)
    total_improvement = ((total_eager - total_lazy) / total_eager * 100) if total_eager > 0 else 0

    summary = {
        'total_eager_time': total_eager,
        'total_lazy_time': total_lazy,
        'total_improvement_percent': total_improvement,
        'time_saved': total_eager - total_lazy,
        'tool_breakdown': dict(zip(tool_names, list(zip(eager_avgs, lazy_avgs, improvements))))
    }

    with open(f'{output_dir}/performance-summary.json', 'w') as f:
        json.dump(summary, f, indent=2)

    print(f"Summary saved to {output_dir}/performance-summary.json")

    return summary

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 generate_plots.py <data_file> <output_dir>")
        sys.exit(1)

    data_file = sys.argv[1]
    output_dir = sys.argv[2]

    Path(output_dir).mkdir(parents=True, exist_ok=True)

    data = load_data(data_file)
    if not data:
        print("No data found")
        sys.exit(1)

    summary = create_comparison_chart(data, output_dir)

    if summary:
        print(f"\nPerformance Summary:")
        print(f"Total Eager Loading: {summary['total_eager_time']:.3f}s")
        print(f"Total Lazy Loading: {summary['total_lazy_time']:.3f}s")
        print(f"Overall Improvement: {summary['total_improvement_percent']:.1f}%")
        print(f"Time Saved: {summary['time_saved']:.3f}s")

if __name__ == "__main__":
    main()
EOF

    chmod +x "$script_file"
    log_success "Visualization script generated: $script_file"
}

# Function to generate plots
generate_plots() {
    local data_file="$1"

    if [[ ! -f "$data_file" ]]; then
        log_warning "No benchmark data found. Run benchmark first."
        return 1
    fi

    log_info "Generating visualizations..."

    # Generate the Python script
    generate_visualization_script "$data_file"

    # Check if Python and matplotlib are available
    if ! command -v python3 &> /dev/null; then
        log_warning "Python3 not found. Install Python3 to generate plots."
        return 1
    fi

    # Try to install matplotlib if not available
    if ! python3 -c "import matplotlib" 2>/dev/null; then
        log_info "Matplotlib not available. Skipping plot generation."
        log_info "To enable plots, install: pip3 install matplotlib pandas numpy"
        return 0
    fi

    # Generate plots
    local script_file="$PLOTS_DIR/generate_plots.py"
    if python3 "$script_file" "$data_file" "$PLOTS_DIR"; then
        log_success "Plots generated successfully!"

        # Display summary
        if [[ -f "$PLOTS_DIR/performance-summary.json" ]]; then
            local summary
            summary=$(cat "$PLOTS_DIR/performance-summary.json")
            local total_eager
            total_eager=$(echo "$summary" | jq -r '.total_eager_time' 2>/dev/null || echo "0")
            local total_lazy
            total_lazy=$(echo "$summary" | jq -r '.total_lazy_time' 2>/dev/null || echo "0")
            local improvement
            improvement=$(echo "$summary" | jq -r '.total_improvement_percent' 2>/dev/null || echo "0")

            print_section "Benchmark Results"
            print_status "INFO" "Total Eager Loading: ${total_eager}s"
            print_status "INFO" "Total Lazy Loading: ${total_lazy}s"
            print_status "SUCCESS" "Overall Improvement: ${improvement}%"
        fi
    else
        log_warning "Failed to generate plots"
    fi
}

# Function to update README with benchmark results
update_readme() {
    local data_file="$1"

    if [[ ! -f "$data_file" ]]; then
        log_warning "No benchmark data found. Run benchmark first."
        return 1
    fi

    log_info "Updating README with benchmark results..."

    # Load summary data
    local summary_file="$PLOTS_DIR/performance-summary.json"
    if [[ ! -f "$summary_file" ]]; then
        log_info "No summary data found. Calculating from benchmark data..."
        # Calculate summary from benchmark data
        local data
        data=$(cat "$BENCHMARK_DATA_FILE" 2>/dev/null || echo "[]")
        if [[ "$data" == "[]" ]]; then
            log_warning "No benchmark data found. Run benchmark first."
            return 1
        fi

        # Calculate totals manually
        local total_eager=0
        local total_lazy=0

        for tool in $TOOLS; do
            local eager_avg
            eager_avg=$(echo "$data" | jq -r "[.[] | select(.tool == \"$tool\" and .type == \"eager\") | .duration] | add / length" 2>/dev/null || echo "0")
            local lazy_avg
            lazy_avg=$(echo "$data" | jq -r "[.[] | select(.tool == \"$tool\" and .type == \"lazy\") | .duration] | add / length" 2>/dev/null || echo "0")

            total_eager=$(echo "$total_eager + $eager_avg" | bc -l 2>/dev/null || echo "$total_eager")
            total_lazy=$(echo "$total_lazy + $lazy_avg" | bc -l 2>/dev/null || echo "$total_lazy")
        done

        local improvement=0
        if (( $(echo "$total_eager > 0" | bc -l 2>/dev/null || echo "0") )); then
            improvement=$(echo "($total_eager - $total_lazy) / $total_eager * 100" | bc -l 2>/dev/null || echo "0")
        fi
    else
        local summary
        summary=$(cat "$summary_file")
        total_eager=$(echo "$summary" | jq -r '.total_eager_time' 2>/dev/null || echo "0")
        total_lazy=$(echo "$summary" | jq -r '.total_lazy_time' 2>/dev/null || echo "0")
        improvement=$(echo "$summary" | jq -r '.total_improvement_percent' 2>/dev/null || echo "0")
    fi

    local time_saved
    time_saved=$(echo "$total_eager - $total_lazy" | bc -l 2>/dev/null || echo "0")

    # Update README.md
    local readme_file="README.md"
    if [[ -f "$readme_file" ]]; then
        # Create backup
        cp "$readme_file" "$readme_file.backup"

        # Update the performance metrics section
        sed -i.tmp "s/~[0-9]*% faster startup/~${improvement}% faster startup/" "$readme_file"
        sed -i.tmp "s/Reduced from [0-9.]*s to [0-9.]*s (~[0-9]*% improvement)/Reduced from $(echo "$total_eager + $total_lazy" | bc -l 2>/dev/null || echo "0")s to ${total_lazy}s (~${improvement}% improvement)/" "$readme_file"

        # Add benchmark section if it doesn't exist
        if ! grep -q "## 📊 Performance Benchmark" "$readme_file"; then
            cat >> "$readme_file" << EOF

## 📊 Performance Benchmark

Latest benchmark results from lazy loading optimization:

- **Total Eager Loading Time**: ${total_eager}s
- **Total Lazy Loading Time**: ${total_lazy}s
- **Performance Improvement**: ${improvement}%
- **Time Saved per Shell**: ${time_saved}s

![Lazy Loading Performance](.cache/dotfiles-benchmark/plots/lazy-loading-performance.png)

*Generated on $(date)*
EOF
        fi

        rm -f "$readme_file.tmp"
        log_success "README updated with benchmark results"
    else
        log_warning "README.md not found"
    fi
}

# Function to run complete benchmark
run_benchmark() {
    log_info "Starting lazy loading performance benchmark..."

    # Create directories
    mkdir -p "$BENCHMARK_DATA_DIR" "$RESULTS_DIR" "$PLOTS_DIR"

    # Initialize results array
    local all_results=()

    # Benchmark each tool
    for tool in $TOOLS; do
        if command -v "$tool" &> /dev/null || [[ -d "$HOME/.$tool" ]] || [[ -d "$HOME/.nvm" && "$tool" == "nvm" ]]; then
            echo "[INFO] Benchmarking $tool..." >&2
            local tool_results
            tool_results=$(benchmark_tool "$tool")
            all_results+=("$tool_results")
        else
            echo "[INFO] Skipping $tool (not installed)" >&2
        fi
    done

    # Combine all results properly
    local combined_data="["
    local first=true
    for result in "${all_results[@]}"; do
        if [[ "$first" == "true" ]]; then
            combined_data+="${result#\[}"
            combined_data="${combined_data%\]}"
            first=false
        else
            combined_data+=",${result#\[}"
            combined_data="${combined_data%\]}"
        fi
    done
    combined_data+="]"

    # Save data
    echo "$combined_data" > "$BENCHMARK_DATA_FILE"

    # Generate matrix
    generate_performance_matrix "$combined_data"

    # Generate plots
    generate_plots "$BENCHMARK_DATA_FILE"

    # Update README
    update_readme "$BENCHMARK_DATA_FILE"

    log_success "Benchmark complete! Results saved to $BENCHMARK_DATA_DIR"
}

# Function to show benchmark results
show_results() {
    if [[ ! -f "$BENCHMARK_DATA_FILE" ]]; then
        log_warning "No benchmark data found. Run benchmark first."
        return 1
    fi

    log_info "Benchmark results from: $BENCHMARK_DATA_FILE"

    if [[ -f "$RESULTS_DIR/performance-matrix.md" ]]; then
        cat "$RESULTS_DIR/performance-matrix.md"
    else
        cat "$BENCHMARK_DATA_FILE" | jq '.' 2>/dev/null || cat "$BENCHMARK_DATA_FILE"
    fi
}

# Function to clean benchmark data
clean_benchmark_data() {
    rm -rf "$BENCHMARK_DATA_DIR"
    log_success "Benchmark data cleaned"
}

# Main function
main() {
    case "${1:-}" in
        "run")
            run_benchmark
            ;;
        "results")
            show_results
            ;;
        "plots")
            generate_plots "$BENCHMARK_DATA_FILE"
            ;;
        "matrix")
            if [[ -f "$BENCHMARK_DATA_FILE" ]]; then
                local data
                data=$(cat "$BENCHMARK_DATA_FILE")
                generate_performance_matrix "$data"
            else
                log_warning "No benchmark data found. Run benchmark first."
            fi
            ;;
        "update-readme")
            update_readme "$BENCHMARK_DATA_FILE"
            ;;
        "clean")
            clean_benchmark_data
            ;;
        *)
            echo "Usage: $0 {run|results|plots|matrix|update-readme|clean}"
            echo ""
            echo "Commands:"
            echo "  run           - Run complete benchmark"
            echo "  results       - Show benchmark results"
            echo "  plots         - Generate visualization plots"
            echo "  matrix        - Generate performance matrix"
            echo "  update-readme - Update README with results"
            echo "  clean         - Clean benchmark data"
            echo ""
            echo "Results will be saved to: $BENCHMARK_DATA_DIR"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
