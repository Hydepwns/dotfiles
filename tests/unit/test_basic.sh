#!/usr/bin/env bash

# Basic test to verify testing framework functionality
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../framework/assertions.sh"

describe "Basic Testing Framework Validation"

it "should perform basic assertions correctly"
assert_true "true" "Boolean true assertion"
assert_false "false" "Boolean false assertion"
assert_equals "hello" "hello" "String equality assertion"
assert_not_equals "hello" "world" "String inequality assertion"

it "should handle file operations"
test_file="/tmp/test_$$"
echo "test content" > "$test_file"
assert_file_exists "$test_file" "File should exist after creation"
rm -f "$test_file"
assert_file_not_exists "$test_file" "File should not exist after deletion"

it "should validate commands"
assert_command_success "echo 'test'" "Echo command should succeed"
assert_command_fails "false" "False command should fail"
assert_command_output "echo 'hello'" "hello" "Echo should output expected text"

it "should handle numeric comparisons"
assert_greater_than "10" "5" "10 should be greater than 5"
assert_less_than "3" "7" "3 should be less than 7"
assert_between "5" "1" "10" "5 should be between 1 and 10"

print_test_summary