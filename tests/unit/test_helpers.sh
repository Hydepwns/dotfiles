#!/usr/bin/env bash

# Unit tests for helpers.sh functions
# Tests core utility functions with comprehensive coverage

# Test setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$SCRIPT_DIR/../framework/assertions.sh"
source "$DOTFILES_ROOT/scripts/utils/helpers.sh"

describe "Helper Functions Unit Tests"

# Test logging functions
it "should log messages with appropriate formatting"
setup() {
    # Capture log output
    TEST_LOG_FILE="/tmp/test_log_$$"
}

teardown() {
    rm -f "$TEST_LOG_FILE"
}

# Test log_info function
log_info "Test info message" > "$TEST_LOG_FILE" 2>&1
assert_file_exists "$TEST_LOG_FILE" "Log file should be created"
assert_command_output_contains "cat $TEST_LOG_FILE" "INFO" "Log should contain INFO level"

# Test log_success function  
log_success "Test success message" > "$TEST_LOG_FILE" 2>&1
assert_command_output_contains "cat $TEST_LOG_FILE" "SUCCESS" "Log should contain SUCCESS level"

# Test log_warning function
log_warning "Test warning message" > "$TEST_LOG_FILE" 2>&1
assert_command_output_contains "cat $TEST_LOG_FILE" "WARNING" "Log should contain WARNING level"

# Test log_error function
log_error "Test error message" > "$TEST_LOG_FILE" 2>&1
assert_command_output_contains "cat $TEST_LOG_FILE" "ERROR" "Log should contain ERROR level"

# Test file existence functions
it "should correctly detect file existence"
test_file=$(create_test_file "test_file.txt" "test content")
assert_true "$(file_exists "$test_file" && echo true || echo false)" "file_exists should return true for existing file"
assert_false "$(file_exists "/nonexistent/file" && echo true || echo false)" "file_exists should return false for non-existing file"

# Test directory functions
it "should handle directory operations correctly"
test_dir="$TEST_FIXTURES_DIR/test_directory"
mkdir -p "$test_dir"
assert_true "$(dir_exists "$test_dir" && echo true || echo false)" "dir_exists should return true for existing directory"
assert_false "$(dir_exists "/nonexistent/directory" && echo true || echo false)" "dir_exists should return false for non-existing directory"

# Test ensure_dir function
it "should create directories when they don't exist"
new_dir="$TEST_FIXTURES_DIR/new_directory"
ensure_dir "$new_dir"
assert_dir_exists "$new_dir" "ensure_dir should create directory"

# Test backup_file function
it "should create backups of existing files"
original_file=$(create_test_file "original.txt" "original content")
backup_file "$original_file"
assert_command_success "ls ${original_file}.backup.*" "Backup file should be created"

# Test has_command function
it "should detect command availability correctly"
assert_true "$(has_command "bash" && echo true || echo false)" "has_command should return true for bash"
assert_false "$(has_command "nonexistent_command_12345" && echo true || echo false)" "has_command should return false for non-existing command"

# Test configuration functions
it "should read configuration values correctly"
config_file=$(create_test_file "test.conf" "key1=value1
key2=value2
key3='quoted value'")

result=$(read_config_value "key1" "$config_file")
assert_equals "value1" "$result" "Should read simple key-value pair"

result=$(read_config_value "key2" "$config_file")
assert_equals "value2" "$result" "Should read second key-value pair"

result=$(read_config_value "key3" "$config_file")
assert_equals "quoted value" "$result" "Should handle quoted values"

result=$(read_config_value "nonexistent" "$config_file" "default")
assert_equals "default" "$result" "Should return default for non-existent key"

# Test boolean configuration checking
it "should correctly identify enabled configuration values"
bool_config=$(create_test_file "bool.conf" "feature1=true
feature2=false
feature3=1
feature4=0
feature5=yes
feature6=no")

assert_true "$(is_config_enabled "feature1" "$bool_config" && echo true || echo false)" "Should recognize 'true' as enabled"
assert_false "$(is_config_enabled "feature2" "$bool_config" && echo true || echo false)" "Should recognize 'false' as disabled"
assert_true "$(is_config_enabled "feature3" "$bool_config" && echo true || echo false)" "Should recognize '1' as enabled"
assert_false "$(is_config_enabled "feature4" "$bool_config" && echo true || echo false)" "Should recognize '0' as disabled"
assert_true "$(is_config_enabled "feature5" "$bool_config" && echo true || echo false)" "Should recognize 'yes' as enabled"
assert_false "$(is_config_enabled "feature6" "$bool_config" && echo true || echo false)" "Should recognize 'no' as disabled"

# Test git repository functions
it "should detect git repositories correctly"
if command -v git >/dev/null 2>&1; then
    # We should be in a git repo (dotfiles)
    assert_true "$(is_git_repo && echo true || echo false)" "Should detect git repository"
    
    # Test in non-git directory
    temp_dir=$(mktemp -d)
    (cd "$temp_dir" && assert_false "$(is_git_repo && echo true || echo false)" "Should detect non-git directory")
    rm -rf "$temp_dir"
else
    skip_test "Git not available for testing"
fi

# Test argument validation
it "should validate function arguments correctly"
validate_args 2 "arg1" "arg2"
assert_equals "0" "$?" "Should pass validation with correct number of args"

validate_args 3 "arg1" "arg2" 2>/dev/null
assert_not_equals "0" "$?" "Should fail validation with insufficient args"

validate_args 2 "arg1" "" 2>/dev/null
assert_not_equals "0" "$?" "Should fail validation with empty args"

# Test performance assertions
it "should measure execution time correctly"
assert_execution_time_under "sleep 0.1" 0.2 "Simple command should execute quickly"

# Property-based testing examples
it "should handle random inputs correctly"
for i in {1..10}; do
    random_string=$(generate_random_string 10)
    assert_greater_than "${#random_string}" "0" "Random string should not be empty"
    assert_equals "10" "${#random_string}" "Random string should be requested length"
done

for i in {1..10}; do
    random_number=$(generate_random_number 1 100)
    assert_between "$random_number" "1" "100" "Random number should be in range"
done

# Test mock functionality
it "should support function mocking"
original_output=$(echo "original")
mock_function "echo" "printf 'mocked'"
mocked_output=$(echo "test")
assert_equals "mocked" "$mocked_output" "Function should be mocked"

restore_function "echo"
restored_output=$(echo "restored")
assert_equals "restored" "$restored_output" "Function should be restored"

# Performance test for critical functions
it "should execute helper functions efficiently"
assert_execution_time_under "has_command bash" 0.1 "has_command should be fast"
assert_execution_time_under "file_exists /etc/passwd" 0.1 "file_exists should be fast"
assert_execution_time_under "dir_exists /tmp" 0.1 "dir_exists should be fast"

# Cleanup
teardown
cleanup_test_files

# Print test results
print_test_summary