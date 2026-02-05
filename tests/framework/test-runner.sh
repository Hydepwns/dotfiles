#!/usr/bin/env bash

# Advanced test runner for dotfiles
# Provides comprehensive testing with coverage analysis, parallel execution, and detailed reporting

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
UTILS_DIR="$DOTFILES_ROOT/scripts/utils"
[ -f "$UTILS_DIR/common.sh" ] && source "$UTILS_DIR/common.sh"

setup_error_handling

# Test framework configuration
TEST_DIR="$SCRIPT_DIR/.."
FIXTURES_DIR="$TEST_DIR/fixtures"
RESULTS_DIR="$TEST_DIR/results"
COVERAGE_DIR="$TEST_DIR/coverage"
TEST_REPORT="$RESULTS_DIR/test-report-$(date +%Y%m%d_%H%M%S).json"

# Test execution configuration
PARALLEL_JOBS="${TEST_PARALLEL_JOBS:-4}"
TEST_TIMEOUT="${TEST_TIMEOUT:-300}"  # 5 minutes default
COVERAGE_TARGET="${COVERAGE_TARGET:-80}"

# Test statistics
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
declare -A TEST_RESULTS
declare -A FUNCTION_COVERAGE

# Test discovery and execution
discover_tests() {
    local test_pattern="${1:-test_*.sh}"
    local test_dir="${2:-$TEST_DIR}"

    find "$test_dir" -name "$test_pattern" -type f -executable | sort
}

# Initialize test environment
setup_test_environment() {
    # Create necessary directories
    mkdir -p "$RESULTS_DIR" "$COVERAGE_DIR" "$FIXTURES_DIR"

    # Initialize test report
    cat > "$TEST_REPORT" << EOF
{
  "session": {
    "id": "$(date +%s)_$$",
    "start_time": "$(date -Iseconds)",
    "framework_version": "1.0.0",
    "parallel_jobs": $PARALLEL_JOBS,
    "timeout": $TEST_TIMEOUT,
    "coverage_target": $COVERAGE_TARGET
  },
  "environment": {
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "shell": "$SHELL",
    "bash_version": "$BASH_VERSION",
    "hostname": "$(hostname)"
  },
  "tests": {},
  "coverage": {},
  "summary": {}
}
EOF

    log_info "Test environment initialized"
    log_info "Results directory: $RESULTS_DIR"
    log_info "Coverage directory: $COVERAGE_DIR"
}

# Execute a single test file
execute_test() {
    local test_file="$1"
    local test_name
    test_name="$(basename "$test_file" .sh)"

    log_info "Running test: $test_name"

    local start_time end_time duration exit_code=0
    start_time=$(date +%s.%N)

    # Create test output files
    local test_stdout="$RESULTS_DIR/${test_name}.stdout"
    local test_stderr="$RESULTS_DIR/${test_name}.stderr"
    local test_coverage="$COVERAGE_DIR/${test_name}.coverage"

    # Execute test with timeout and coverage
    (
        export TEST_FIXTURES_DIR="$FIXTURES_DIR"
        export TEST_RESULTS_DIR="$RESULTS_DIR"
        export TEST_NAME="$test_name"

        # Enable coverage tracking
        if [[ "${ENABLE_COVERAGE:-true}" == "true" ]]; then
            export COVERAGE_FILE="$test_coverage"
        fi

        timeout "$TEST_TIMEOUT" bash "$test_file"
    ) > "$test_stdout" 2> "$test_stderr" || exit_code=$?

    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    # Determine test result
    local status
    if [[ $exit_code -eq 124 ]]; then
        status="timeout"
        ((TESTS_FAILED++))
    elif [[ $exit_code -eq 0 ]]; then
        status="passed"
        ((TESTS_PASSED++))
    elif [[ $exit_code -eq 77 ]]; then
        status="skipped"
        ((TESTS_SKIPPED++))
    else
        status="failed"
        ((TESTS_FAILED++))
    fi

    ((TESTS_TOTAL++))
    # shellcheck disable=SC2034
    TEST_RESULTS["$test_name"]="$status"

    # Update test report
    update_test_report "$test_name" "$status" "$duration" "$exit_code" "$test_stdout" "$test_stderr"

    # Display result
    case "$status" in
        "passed")
            echo -e "  ${GREEN}+${NC} $test_name (${duration}s)"
            ;;
        "failed")
            echo -e "  ${RED}-${NC} $test_name (exit: $exit_code, ${duration}s)"
            ;;
        "skipped")
            echo -e "  ${YELLOW}↷${NC} $test_name (skipped)"
            ;;
        "timeout")
            echo -e "  ${RED}T${NC} $test_name (timeout after ${TEST_TIMEOUT}s)"
            ;;
    esac
}

# Update test report with results
update_test_report() {
    local test_name="$1" status="$2" duration="$3" exit_code="$4" stdout_file="$5" stderr_file="$6"

    if command -v jq >/dev/null 2>&1; then
        local temp_file="/tmp/test_report_$$.json"

        jq --arg name "$test_name" \
           --arg status "$status" \
           --arg duration "$duration" \
           --arg exit_code "$exit_code" \
           --arg stdout "$(cat "$stdout_file" 2>/dev/null | head -50 || echo "")" \
           --arg stderr "$(cat "$stderr_file" 2>/dev/null | head -20 || echo "")" \
           '.tests[$name] = {
             status: $status,
             duration: ($duration | tonumber),
             exit_code: ($exit_code | tonumber),
             stdout: $stdout,
             stderr: $stderr
           }' \
           "$TEST_REPORT" > "$temp_file" && mv "$temp_file" "$TEST_REPORT"
    fi
}

# Execute tests in parallel
run_tests_parallel() {
    local test_files=("$@")
    local pids=()
    local active_jobs=0

    log_info "Running ${#test_files[@]} tests with $PARALLEL_JOBS parallel jobs"

    for test_file in "${test_files[@]}"; do
        # Wait if we've reached the parallel limit
        while [[ $active_jobs -ge $PARALLEL_JOBS ]]; do
            wait -n  # Wait for any job to complete
            ((active_jobs--))
        done

        # Start test in background
        execute_test "$test_file" &
        pids+=($!)
        ((active_jobs++))
    done

    # Wait for all remaining jobs
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# Analyze function coverage
analyze_coverage() {
    log_info "Analyzing test coverage..."

    if [[ ! -d "$COVERAGE_DIR" ]]; then
        log_warning "No coverage data found"
        return
    fi

    # Find all functions in source files
    local total_functions=0
    local covered_functions=0

    # Scan all shell scripts for function definitions
    while IFS= read -r -d '' script_file; do
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\(\) ]]; then
                local func_name="${BASH_REMATCH[1]}"
                ((total_functions++))

                # Check if function was called in any coverage file
                if find "$COVERAGE_DIR" -name "*.coverage" -exec grep -q "$func_name" {} \; 2>/dev/null; then
                    ((covered_functions++))
                    FUNCTION_COVERAGE["$func_name"]="covered"
                else
                    # shellcheck disable=SC2034
                    FUNCTION_COVERAGE["$func_name"]="uncovered"
                fi
            fi
        done < "$script_file"
    done < <(find "$DOTFILES_ROOT/scripts" -name "*.sh" -type f -print0)

    # Calculate coverage percentage
    local coverage_percent=0
    if [[ $total_functions -gt 0 ]]; then
        coverage_percent=$(( (covered_functions * 100) / total_functions ))
    fi

    # Update report with coverage
    if command -v jq >/dev/null 2>&1; then
        local temp_file="/tmp/coverage_$$.json"

        jq --arg total "$total_functions" \
           --arg covered "$covered_functions" \
           --arg percent "$coverage_percent" \
           --arg target "$COVERAGE_TARGET" \
           '.coverage = {
             total_functions: ($total | tonumber),
             covered_functions: ($covered | tonumber),
             coverage_percent: ($percent | tonumber),
             target_percent: ($target | tonumber),
             meets_target: (($percent | tonumber) >= ($target | tonumber))
           }' \
           "$TEST_REPORT" > "$temp_file" && mv "$temp_file" "$TEST_REPORT"
    fi

    echo ""
    log_info "Coverage Analysis Results:"
    echo "  Total functions: $total_functions"
    echo "  Covered functions: $covered_functions"
    echo "  Coverage: ${coverage_percent}%"
    echo "  Target: ${COVERAGE_TARGET}%"

    if [[ $coverage_percent -ge $COVERAGE_TARGET ]]; then
        echo -e "  ${GREEN}+${NC} Coverage target met!"
    else
        echo -e "  ${YELLOW}!${NC} Coverage below target (need $((COVERAGE_TARGET - coverage_percent))% more)"
    fi
}

# Generate final test report
generate_final_report() {
    local end_time total_duration success_rate
    end_time=$(date -Iseconds)
    total_duration=$(echo "$(date +%s) - $(jq -r '.session.start_time' "$TEST_REPORT" | date -f - +%s)" | bc 2>/dev/null || echo "0")
    success_rate=0

    if [[ $TESTS_TOTAL -gt 0 ]]; then
        success_rate=$(( (TESTS_PASSED * 100) / TESTS_TOTAL ))
    fi

    # Update final report
    if command -v jq >/dev/null 2>&1; then
        local temp_file="/tmp/final_report_$$.json"

        jq --arg end_time "$end_time" \
           --arg duration "$total_duration" \
           --arg total "$TESTS_TOTAL" \
           --arg passed "$TESTS_PASSED" \
           --arg failed "$TESTS_FAILED" \
           --arg skipped "$TESTS_SKIPPED" \
           --arg success_rate "$success_rate" \
           '.session.end_time = $end_time |
            .session.duration = ($duration | tonumber) |
            .summary = {
              total: ($total | tonumber),
              passed: ($passed | tonumber),
              failed: ($failed | tonumber),
              skipped: ($skipped | tonumber),
              success_rate: ($success_rate | tonumber)
            }' \
           "$TEST_REPORT" > "$temp_file" && mv "$temp_file" "$TEST_REPORT"
    fi

    # Display summary
    echo ""
    echo "========================================="
    echo "Test Execution Summary"
    echo "========================================="
    echo "Total Tests: $TESTS_TOTAL"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo "Skipped: $TESTS_SKIPPED"
    echo "Success Rate: ${success_rate}%"
    echo "Duration: ${total_duration}s"
    echo ""
    echo "Full Report: $TEST_REPORT"
    echo "========================================="
}

# Main test execution function
run_test_suite() {
    local test_pattern="${1:-test_*.sh}"
    local test_directory="${2:-$TEST_DIR}"

    setup_test_environment

    # Discover tests
    local test_files
    mapfile -t test_files < <(discover_tests "$test_pattern" "$test_directory")

    if [[ ${#test_files[@]} -eq 0 ]]; then
        log_error "No test files found matching pattern: $test_pattern"
        return $EXIT_FILE_NOT_FOUND
    fi

    log_info "Discovered ${#test_files[@]} test files"

    # Execute tests
    if [[ $PARALLEL_JOBS -gt 1 ]]; then
        run_tests_parallel "${test_files[@]}"
    else
        for test_file in "${test_files[@]}"; do
            execute_test "$test_file"
        done
    fi

    # Analyze coverage
    analyze_coverage

    # Generate final report
    generate_final_report

    # Return appropriate exit code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        return $EXIT_SUCCESS
    else
        return $EXIT_FAILURE
    fi
}

# Command-line interface
main() {
    case "${1:-run}" in
        "run")
            run_test_suite "${2:-test_*.sh}" "${3:-$TEST_DIR}"
            ;;
        "discover")
            discover_tests "${2:-test_*.sh}" "${3:-$TEST_DIR}"
            ;;
        "coverage")
            analyze_coverage
            ;;
        "clean")
            rm -rf "$RESULTS_DIR" "$COVERAGE_DIR"
            log_info "Cleaned test results and coverage data"
            ;;
        "report")
            if [[ -f "$TEST_REPORT" ]]; then
                if command -v jq >/dev/null 2>&1; then
                    jq '.' "$TEST_REPORT"
                else
                    cat "$TEST_REPORT"
                fi
            else
                log_error "No test report found. Run tests first."
                exit $EXIT_FILE_NOT_FOUND
            fi
            ;;
        "--help"|"-h"|"help")
            cat << EOF
Usage: $0 [command] [options]

Commands:
  run [pattern] [dir]  - Run test suite (default)
  discover [pattern]   - Discover test files
  coverage            - Analyze test coverage
  clean              - Clean test results
  report             - Display test report
  help               - Show this help

Options:
  TEST_PARALLEL_JOBS  - Number of parallel test jobs (default: 4)
  TEST_TIMEOUT       - Test timeout in seconds (default: 300)
  COVERAGE_TARGET    - Coverage target percentage (default: 80)
  ENABLE_COVERAGE    - Enable coverage tracking (default: true)

Examples:
  $0 run                        # Run all tests
  $0 run "unit_*.sh"           # Run unit tests only
  $0 discover "integration_*.sh" # Find integration tests
  $0 coverage                  # Show coverage analysis
EOF
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 --help' for usage information."
            exit $EXIT_INVALID_ARGS
            ;;
    esac
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
