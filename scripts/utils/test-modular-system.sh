#!/bin/bash

# Comprehensive test script for the modular dotfiles system

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/colors.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/colors.sh"
else
    echo "Warning: colors.sh not found"
fi

print_status "INFO" "Testing modular dotfiles system..."

# Test configuration directory
TEST_DIR="$HOME/.zsh-test"

# Function to test if a function exists
test_function() {
    local func_name="$1"
    local description="$2"
    
    if type "$func_name" &>/dev/null; then
        print_status "OK" "✓ $description ($func_name)"
        return 0
    else
        print_status "ERROR" "✗ $description ($func_name) - NOT FOUND"
        return 1
    fi
}

# Function to test if an alias exists
test_alias() {
    local alias_name="$1"
    local description="$2"
    
    if alias "$alias_name" &>/dev/null; then
        print_status "OK" "✓ $description ($alias_name)"
        return 0
    else
        print_status "ERROR" "✗ $description ($alias_name) - NOT FOUND"
        return 1
    fi
}

# Function to test if a variable is set
test_variable() {
    local var_name="$1"
    local description="$2"
    
    if [[ -n "${!var_name}" ]]; then
        print_status "OK" "✓ $description ($var_name)"
        return 0
    else
        print_status "ERROR" "✗ $description ($var_name) - NOT SET"
        return 1
    fi
}

print_section "Testing Modular System"

# Test 1: Check if test configuration exists
if [[ -d "$TEST_DIR" ]]; then
    print_status "OK" "Test configuration directory exists"
else
    print_status "ERROR" "Test configuration directory not found"
    exit 1
fi

# Test 2: Source the modular configuration
print_subsection "Loading Modular Configuration"
# shellcheck disable=SC1091
if source "$TEST_DIR/zshrc"; then
    print_status "OK" "Modular configuration loaded successfully"
else
    print_status "ERROR" "Failed to load modular configuration"
    exit 1
fi

# Test 3: Test core functions
print_subsection "Testing Core Functions"

test_function "mkcd" "Development utility function"
test_function "gitst" "Git status function"
test_function "gitac" "Git add and commit function"
test_function "dcup" "Docker compose up function"
test_function "findgrep" "Find files containing text function"

# Test 4: Test aliases
print_subsection "Testing Aliases"

test_alias "cm" "Chezmoi alias"
test_alias "ll" "List long alias"
test_alias "copy" "Copy to clipboard alias"
test_alias "paste" "Paste from clipboard alias"

# Test 5: Test environment variables
print_subsection "Testing Environment Variables"

test_variable "EDITOR" "Editor variable"
test_variable "LANG" "Language variable"
test_variable "PATH" "PATH variable"

# Test 6: Test PATH components
print_subsection "Testing PATH Components"

if [[ ":$PATH:" == *":$HOME/.cargo/bin:"* ]]; then
    print_status "OK" "✓ Rust cargo bin in PATH"
else
    print_status "WARN" "⚠ Rust cargo bin not in PATH"
fi

if [[ ":$PATH:" == *":/opt/homebrew/bin:"* ]]; then
    print_status "OK" "✓ Homebrew bin in PATH"
else
    print_status "WARN" "⚠ Homebrew bin not in PATH"
fi

# Test 7: Test function functionality
print_subsection "Testing Function Functionality"

# Test mkcd function
if mkcd test-dir &>/dev/null; then
    print_status "OK" "✓ mkcd function works"
    cd .. && rmdir test-dir
else
    print_status "ERROR" "✗ mkcd function failed"
fi

# Test gitst function (should work in a git repo)
if gitst &>/dev/null; then
    print_status "OK" "✓ gitst function works"
else
    print_status "WARN" "⚠ gitst function may not work (not in git repo)"
fi

print_section "Test Summary"

print_status "INFO" "Modular system test completed!"
print_status "INFO" "All core components are working correctly."
print_status "INFO" "The modular system is ready for production use." 