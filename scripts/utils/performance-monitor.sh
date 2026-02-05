#!/usr/bin/env bash
set -euo pipefail

# Shell startup performance benchmark
# Usage: make perf

RUNS="${2:-5}"

measure() {
    echo "Benchmarking zsh startup ($RUNS runs)..."
    echo ""

    local total=0
    local times=()

    for i in $(seq 1 "$RUNS"); do
        local start end dur
        start=$(date +%s%N)
        zsh -i -c 'exit' 2>/dev/null
        end=$(date +%s%N)
        dur=$(( (end - start) / 1000000 ))
        times+=("$dur")
        printf "  run %d: %dms\n" "$i" "$dur"
        total=$((total + dur))
    done

    local avg=$((total / RUNS))
    echo ""
    echo "---"
    printf "Average: %dms\n" "$avg"

    if [[ "$avg" -lt 200 ]]; then
        echo "Status: fast (<200ms)"
    elif [[ "$avg" -lt 500 ]]; then
        echo "Status: moderate (200-500ms)"
    else
        echo "Status: slow (>500ms) -- check lazy loading"
    fi
}

report() {
    echo "Shell startup breakdown:"
    echo ""

    # Time bare zsh
    local start end bare
    start=$(date +%s%N)
    zsh --no-rcs -i -c 'exit' 2>/dev/null
    end=$(date +%s%N)
    bare=$(( (end - start) / 1000000 ))

    # Time with rc
    start=$(date +%s%N)
    zsh -i -c 'exit' 2>/dev/null
    end=$(date +%s%N)
    local full=$(( (end - start) / 1000000 ))

    local config=$((full - bare))
    printf "  Bare zsh:    %dms\n" "$bare"
    printf "  With config: %dms\n" "$full"
    printf "  Config cost: %dms\n" "$config"
    echo ""

    # Check lazy load times if available
    local lazy_output
    lazy_output=$(zsh -i -c 'echo "$LAZY_LOAD_TIMES"' 2>/dev/null || true)
    if [[ -n "$lazy_output" ]]; then
        echo "Lazy load times:"
        echo "  $lazy_output"
    fi
}

case "${1:-measure}" in
    measure) measure ;;
    report)  report ;;
    *)
        echo "Usage: $0 {measure|report}"
        echo "  measure - Benchmark shell startup (default)"
        echo "  report  - Show startup breakdown"
        exit 1
        ;;
esac
