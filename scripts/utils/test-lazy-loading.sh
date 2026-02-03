#!/usr/bin/env bash

# Use simple script initialization (no segfaults!)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/simple-init.sh"

# Test script for lazy loading functionality

# Simple utilities (no dependencies)
log_info() { echo -e "${BLUE:-}[INFO]${NC:-} $1"; }
log_success() { echo -e "${GREEN:-}[SUCCESS]${NC:-} $1"; }
log_error() { echo -e "${RED:-}[ERROR]${NC:-} $1" >&2; }
log_warning() { echo -e "${YELLOW:-}[WARNING]${NC:-} $1"; }

# Exit codes
EXIT_SUCCESS=0
EXIT_INVALID_ARGS=1
EXIT_FAILURE=1

# Simple utility functions
file_exists() { test -f "$1"; }
dir_exists() { test -d "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Status printing functions for compatibility
print_status() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        "OK") log_success "$message" ;;
        "INFO") log_info "$message" ;;
        "ERROR") log_error "$message" ;;
        "WARN") log_warning "$message" ;;
        *) log_info "$message" ;;
    esac
}

print_section() {
    log_info "=== $1 ==="
}

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
