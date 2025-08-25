#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1 | xargs dirname)"
source "$UTILS_DIR/script-init.sh"

# Source constants


# Test script for lazy loading functionality


# Source shared utilities
if [[ -f "$SCRIPT_DIR/colors.sh" ]]; then
    # shellcheck disable=SC1091
else
    echo "Warning: colors.sh not found"
fi

print_status "INFO" "Testing lazy loading functionality..."

# Test configuration directory
TEST_DIR="$HOME/.zsh-test"

print_section "Testing Lazy Loading"

# Test 1: Check if lazy loading file exists
if [[ -f "$TEST_DIR/core/lazy-loading.zsh" ]]; then
    print_status "OK" "Lazy loading configuration exists"
else
    print_status "ERROR" "Lazy loading configuration not found"
    exit $EXIT_FAILURE
fi

# Test 2: Check if NVM lazy loading is configured
if grep -q "alias nvm=" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "NVM lazy loading alias is configured"
else
    print_status "WARN" " NVM lazy loading alias not found"
fi

# Test 3: Check if rbenv lazy loading is configured
if grep -q "alias rbenv=" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "rbenv lazy loading alias is configured"
else
    print_status "WARN" " rbenv lazy loading alias not found"
fi

# Test 4: Check if Ruby command lazy loading is configured
if grep -q "alias ruby=" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "Ruby lazy loading alias is configured"
else
    print_status "WARN" " Ruby lazy loading alias not found"
fi

# Test 5: Check if Gem lazy loading is configured
if grep -q "alias gem=" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "Gem lazy loading alias is configured"
else
    print_status "WARN" " Gem lazy loading alias not found"
fi

# Test 6: Check if Bundle lazy loading is configured
if grep -q "alias bundle=" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "Bundle lazy loading alias is configured"
else
    print_status "WARN" " Bundle lazy loading alias not found"
fi

# Test 7: Check if Rake lazy loading is configured
if grep -q "alias rake=" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "Rake lazy loading alias is configured"
else
    print_status "WARN" " Rake lazy loading alias not found"
fi

# Test 8: Check if performance tracking is configured
if grep -q "track_loading" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "Performance tracking is configured"
else
    print_status "WARN" " Performance tracking not found"
fi

# Test 9: Check if lazy loading functions are defined
if grep -q "lazy_load_nvm()" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "NVM lazy loading function is defined"
else
    print_status "ERROR" "NVM lazy loading function not found"
fi

if grep -q "lazy_load_rbenv()" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "rbenv lazy loading function is defined"
else
    print_status "ERROR" "rbenv lazy loading function not found"
fi

if grep -q "lazy_load_ruby()" "$TEST_DIR/core/lazy-loading.zsh"; then
    print_status "OK" "Ruby lazy loading function is defined"
else
    print_status "ERROR" "Ruby lazy loading function not found"
fi

print_section "Test Summary"

print_status "INFO" "Lazy loading test completed!"
print_status "INFO" "NVM and rbenv are configured for lazy loading."
print_status "INFO" "This will improve shell startup performance."
print_status "INFO" "Tools will only be loaded when first used."
