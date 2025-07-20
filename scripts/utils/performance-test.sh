#!/bin/bash
# Performance testing script for dotfiles
# This script measures various performance metrics

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}✗${NC} $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
    esac
}

# Function to measure time
measure_time() {
    local command="$1"
    local description="$2"

    echo -n "Testing $description... "
    local start_time
    start_time=$(date +%s.%N)
    eval "$command" > /dev/null 2>&1
    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $start_time" | bc -l)
    printf "%.3fs\n" "$duration"
}

echo "🔍 Performance Testing for DROO's dotfiles"
echo "=========================================="

# Test zsh startup time (skipped due to template syntax issues)
echo -e "\n${BLUE}Shell Performance Tests:${NC}"
echo "⚠ Skipping zsh startup test - configuration contains unprocessed template syntax"
echo "  To test zsh startup, first run: chezmoi apply"

# Test chezmoi operations (with timeouts)
echo -e "\n${BLUE}Chezmoi Performance Tests:${NC}"
echo "Testing chezmoi operations with timeouts..."
if timeout 10s chezmoi status > /dev/null 2>&1; then
    echo "✓ chezmoi status successful"
else
    echo "⚠ chezmoi status took too long or failed"
fi

if timeout 10s chezmoi diff > /dev/null 2>&1; then
    echo "✓ chezmoi diff successful"
else
    echo "⚠ chezmoi diff took too long or failed"
fi

if timeout 10s chezmoi apply --dry-run > /dev/null 2>&1; then
    echo "✓ chezmoi dry-run successful"
else
    echo "⚠ chezmoi dry-run took too long or failed"
fi

# Test tool detection (skip sourcing .zshrc due to template syntax)
echo -e "\n${BLUE}Tool Detection Performance:${NC}"
echo "Skipping .zshrc sourcing test (contains unprocessed template syntax)"

# Test file operations (with timeout)
echo -e "\n${BLUE}File System Performance:${NC}"
echo "Testing file search performance..."
if timeout 10s find ~ -name '*.zsh' -type f | head -10 > /dev/null 2>&1; then
    echo "✓ file search successful"
else
    echo "⚠ file search took too long or failed"
fi

# Memory usage
echo -e "\n${BLUE}Memory Usage:${NC}"
echo "Current shell memory usage:"
ps -o pid,ppid,cmd,%mem,%cpu --forest -p $$ 2>/dev/null || echo "Memory info not available"

# Profile zsh startup with detailed timing (skipped)
echo -e "\n${BLUE}Detailed Zsh Startup Profile:${NC}"
echo "⚠ Skipping detailed zsh profile - configuration contains unprocessed template syntax"
echo "  To profile zsh startup, first run: chezmoi apply"

# Test specific tool loading times
echo -e "\n${BLUE}Tool Loading Performance:${NC}"

# Test Oh My Zsh loading (with timeout)
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "Testing Oh My Zsh loading..."
    if timeout 10s bash -c "source $HOME/.oh-my-zsh/oh-my-zsh.sh" > /dev/null 2>&1; then
        echo "✓ Oh My Zsh loading successful"
    else
        echo "⚠ Oh My Zsh loading took too long or failed"
    fi
else
    print_status "INFO" "Oh My Zsh not installed"
fi

# Test asdf loading (with timeout)
if command -v asdf &> /dev/null; then
    echo "Testing asdf loading..."
    if timeout 10s bash -c "source $(brew --prefix asdf)/libexec/asdf.sh" > /dev/null 2>&1; then
        echo "✓ asdf loading successful"
    else
        echo "⚠ asdf loading took too long or failed"
    fi
else
    print_status "INFO" "asdf not installed"
fi

# Test NVM loading (with timeout)
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    echo "Testing NVM loading..."
    if timeout 10s bash -c "source $HOME/.nvm/nvm.sh" > /dev/null 2>&1; then
        echo "✓ NVM loading successful"
    else
        echo "⚠ NVM loading took too long or failed"
    fi
else
    print_status "INFO" "NVM not installed"
fi

# Test rbenv loading (with timeout)
if command -v rbenv &> /dev/null; then
    echo "Testing rbenv loading..."
    if timeout 10s bash -c "eval \"\$(rbenv init -)\"" > /dev/null 2>&1; then
        echo "✓ rbenv loading successful"
    else
        echo "⚠ rbenv loading took too long or failed"
    fi
else
    print_status "INFO" "rbenv not installed"
fi

# Performance recommendations
echo -e "\n${BLUE}Performance Recommendations:${NC}"

# Check for slow loading tools
if [[ -f "$HOME/.zshrc" ]]; then
    echo "Analyzing .zshrc for potential optimizations..."

    # Check for expensive operations
    if grep -q "nvm use" "$HOME/.zshrc"; then
        print_status "WARN" "Consider lazy-loading NVM to improve startup time"
    fi

    if grep -q "rbenv init" "$HOME/.zshrc"; then
        print_status "WARN" "Consider lazy-loading rbenv to improve startup time"
    fi

    if grep -q "asdf" "$HOME/.zshrc"; then
        print_status "WARN" "Consider lazy-loading asdf to improve startup time"
    fi
fi

# Check for unused tools
echo -e "\n${BLUE}Tool Usage Analysis:${NC}"
tools=("nvm" "rbenv" "asdf" "elixir" "lua" "direnv" "devenv" "nix")
for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        print_status "OK" "$tool is installed and available"
    else
        print_status "INFO" "$tool is not installed"
    fi
done

echo -e "\n${BLUE}Performance test complete!${NC}"
echo "=========================================="
