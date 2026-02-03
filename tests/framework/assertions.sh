#!/usr/bin/env bash

# Test assertion framework for dotfiles
# Provides comprehensive assertion functions for robust testing

# Assertion configuration
ASSERTION_COUNT=0
ASSERTION_PASSED=0
ASSERTION_FAILED=0
TEST_FAILED=false

# Colors for test output
if [[ -t 1 ]]; then
    TEST_GREEN='\033[32m'
    TEST_RED='\033[31m'
    TEST_YELLOW='\033[33m'
    TEST_BLUE='\033[34m'
    TEST_RESET='\033[0m'
else
    TEST_GREEN='' TEST_RED='' TEST_YELLOW='' TEST_BLUE='' TEST_RESET=''
fi

# Assertion result tracking
record_assertion() {
    local result="$1"
    local message="$2"
    local expected="${3:-}"
    local actual="${4:-}"
    
    ((ASSERTION_COUNT++))
    
    if [[ "$result" == "pass" ]]; then
        ((ASSERTION_PASSED++))
        echo -e "    ${TEST_GREEN}✓${TEST_RESET} $message"
    else
        ((ASSERTION_FAILED++))
        TEST_FAILED=true
        echo -e "    ${TEST_RED}✗${TEST_RESET} $message"
        
        if [[ -n "$expected" && -n "$actual" ]]; then
            echo -e "      ${TEST_YELLOW}Expected:${TEST_RESET} $expected"
            echo -e "      ${TEST_YELLOW}Actual:${TEST_RESET} $actual"
        fi
    fi
    
    # Record in coverage if enabled
    if [[ -n "${COVERAGE_FILE:-}" ]]; then
        echo "assertion:$message" >> "$COVERAGE_FILE"
    fi
}

# Basic assertions
assert_true() {
    local condition="$1"
    local message="${2:-Assertion should be true}"
    
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "true" "$condition"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Assertion should be false}"
    
    if [[ "$condition" == "false" ]] || [[ "$condition" == "1" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "false" "$condition"
        return 1
    fi
}

# String assertions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "$expected" "$actual"
        return 1
    fi
}

assert_not_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"
    
    if [[ "$expected" != "$actual" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "not $expected" "$actual"
        return 1
    fi
}

assert_contains() {
    local string="$1"
    local substring="$2"
    local message="${3:-String should contain substring}"
    
    if [[ "$string" =~ $substring ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "contains '$substring'" "'$string'"
        return 1
    fi
}

assert_not_contains() {
    local string="$1"
    local substring="$2"
    local message="${3:-String should not contain substring}"
    
    if [[ ! "$string" =~ $substring ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "not contains '$substring'" "'$string'"
        return 1
    fi
}

assert_matches() {
    local string="$1"
    local pattern="$2"
    local message="${3:-String should match pattern}"
    
    if [[ "$string" =~ ^${pattern}$ ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "matches /$pattern/" "'$string'"
        return 1
    fi
}

# Numeric assertions
assert_greater_than() {
    local actual="$1"
    local expected="$2"
    local message="${3:-Value should be greater than expected}"
    
    if (( $(echo "$actual > $expected" | bc -l 2>/dev/null || echo "0") )); then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "> $expected" "$actual"
        return 1
    fi
}

assert_less_than() {
    local actual="$1"
    local expected="$2"
    local message="${3:-Value should be less than expected}"
    
    if (( $(echo "$actual < $expected" | bc -l 2>/dev/null || echo "0") )); then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "< $expected" "$actual"
        return 1
    fi
}

assert_between() {
    local value="$1"
    local min="$2"
    local max="$3"
    local message="${4:-Value should be between min and max}"
    
    if (( $(echo "$value >= $min && $value <= $max" | bc -l 2>/dev/null || echo "0") )); then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "between $min and $max" "$value"
        return 1
    fi
}

# File assertions
assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$file" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "file exists" "file not found: $file"
        return 1
    fi
}

assert_file_not_exists() {
    local file="$1"
    local message="${2:-File should not exist}"
    
    if [[ ! -f "$file" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "file does not exist" "file exists: $file"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist}"
    
    if [[ -d "$dir" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "directory exists" "directory not found: $dir"
        return 1
    fi
}

assert_file_executable() {
    local file="$1"
    local message="${2:-File should be executable}"
    
    if [[ -x "$file" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "executable file" "not executable: $file"
        return 1
    fi
}

assert_file_readable() {
    local file="$1"
    local message="${2:-File should be readable}"
    
    if [[ -r "$file" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "readable file" "not readable: $file"
        return 1
    fi
}

# Command assertions
assert_command_success() {
    local command="$1"
    local message="${2:-Command should succeed}"
    
    if eval "$command" >/dev/null 2>&1; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "exit code 0" "command failed: $command"
        return 1
    fi
}

assert_command_fails() {
    local command="$1"
    local message="${2:-Command should fail}"
    
    if ! eval "$command" >/dev/null 2>&1; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "non-zero exit code" "command succeeded: $command"
        return 1
    fi
}

assert_command_output() {
    local command="$1"
    local expected_output="$2"
    local message="${3:-Command output should match expected}"
    
    local actual_output
    actual_output=$(eval "$command" 2>&1)
    
    if [[ "$actual_output" == "$expected_output" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "$expected_output" "$actual_output"
        return 1
    fi
}

assert_command_output_contains() {
    local command="$1"
    local expected_substring="$2"
    local message="${3:-Command output should contain substring}"
    
    local actual_output
    actual_output=$(eval "$command" 2>&1)
    
    if [[ "$actual_output" =~ $expected_substring ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "contains '$expected_substring'" "'$actual_output'"
        return 1
    fi
}

# Environment assertions
assert_variable_set() {
    local var_name="$1"
    local message="${2:-Variable should be set}"
    
    if [[ -n "${!var_name:-}" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "variable set" "$var_name is unset"
        return 1
    fi
}

assert_variable_unset() {
    local var_name="$1"
    local message="${2:-Variable should be unset}"
    
    if [[ -z "${!var_name:-}" ]]; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "variable unset" "$var_name is set to '${!var_name}'"
        return 1
    fi
}

# Function existence assertions
assert_function_exists() {
    local function_name="$1"
    local message="${2:-Function should exist}"
    
    if declare -f "$function_name" >/dev/null 2>&1; then
        record_assertion "pass" "$message"
        return 0
    else
        record_assertion "fail" "$message" "function exists" "function not found: $function_name"
        return 1
    fi
}

# Performance assertions
assert_execution_time_under() {
    local command="$1"
    local max_time="$2"
    local message="${3:-Execution time should be under threshold}"
    
    local start_time end_time duration
    start_time=$(date +%s.%N)
    
    eval "$command" >/dev/null 2>&1
    local exit_code=$?
    
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "999")
    
    if (( $(echo "$duration < $max_time" | bc -l 2>/dev/null || echo "0") )); then
        record_assertion "pass" "$message (${duration}s < ${max_time}s)"
        return $exit_code
    else
        record_assertion "fail" "$message" "< ${max_time}s" "${duration}s"
        return 1
    fi
}

# Test organization functions
describe() {
    local description="$1"
    echo -e "\n${TEST_BLUE}$description${TEST_RESET}"
}

it() {
    local description="$1"
    echo -e "  ${TEST_YELLOW}→${TEST_RESET} $description"
}

# Test lifecycle functions
setup() {
    # Override this function in test files for setup
    :
}

teardown() {
    # Override this function in test files for cleanup
    :
}

skip_test() {
    local reason="${1:-Test skipped}"
    echo -e "  ${TEST_YELLOW}↷${TEST_RESET} $reason"
    exit 77  # Standard skip exit code
}

# Test summary
print_test_summary() {
    echo ""
    echo "Test Summary:"
    echo "  Assertions: $ASSERTION_COUNT"
    echo "  Passed: $ASSERTION_PASSED"
    echo "  Failed: $ASSERTION_FAILED"
    
    if [[ "$TEST_FAILED" == "true" ]]; then
        echo -e "  ${TEST_RED}Result: FAILED${TEST_RESET}"
        return 1
    else
        echo -e "  ${TEST_GREEN}Result: PASSED${TEST_RESET}"
        return 0
    fi
}

# Property-based testing helpers
generate_random_string() {
    local length="${1:-10}"
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c "$length"
}

generate_random_number() {
    local min="${1:-1}"
    local max="${2:-100}"
    echo $(( RANDOM % (max - min + 1) + min ))
}

# Fixtures and test data management
create_test_file() {
    local filename="$1"
    local content="$2"
    local test_dir="${TEST_FIXTURES_DIR:-/tmp/test_fixtures}"
    
    mkdir -p "$test_dir"
    echo "$content" > "$test_dir/$filename"
    echo "$test_dir/$filename"
}

cleanup_test_files() {
    local test_dir="${TEST_FIXTURES_DIR:-/tmp/test_fixtures}"
    if [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
    fi
}

# Mock function framework
mock_function() {
    local function_name="$1"
    local mock_behavior="$2"
    
    # Save original function if it exists
    if declare -f "$function_name" >/dev/null 2>&1; then
        eval "_original_${function_name}() $(declare -f "$function_name" | sed '1d')"
    fi
    
    # Create mock
    eval "${function_name}() { $mock_behavior; }"
}

restore_function() {
    local function_name="$1"
    
    if declare -f "_original_${function_name}" >/dev/null 2>&1; then
        eval "${function_name}() $(declare -f "_original_${function_name}" | sed '1d')"
        unset -f "_original_${function_name}"
    else
        unset -f "$function_name"
    fi
}

# Export all assertion functions for use in test files
export -f assert_true assert_false assert_equals assert_not_equals
export -f assert_contains assert_not_contains assert_matches
export -f assert_greater_than assert_less_than assert_between
export -f assert_file_exists assert_file_not_exists assert_dir_exists
export -f assert_file_executable assert_file_readable
export -f assert_command_success assert_command_fails
export -f assert_command_output assert_command_output_contains
export -f assert_variable_set assert_variable_unset assert_function_exists
export -f assert_execution_time_under
export -f describe it setup teardown skip_test print_test_summary
export -f generate_random_string generate_random_number
export -f create_test_file cleanup_test_files
export -f mock_function restore_function record_assertion