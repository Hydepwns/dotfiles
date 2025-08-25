#!/usr/bin/env bash

# Use simple script initialization (no segfaults!)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/simple-init.sh"

# Setup script for CI/CD tools and pre-commit hooks
# This script installs and configures development tools for the dotfiles repository

# Simple utilities (no dependencies)
log_info() { echo -e "${BLUE:-}[INFO]${NC:-} $1"; }
log_success() { echo -e "${GREEN:-}[SUCCESS]${NC:-} $1"; }
log_error() { echo -e "${RED:-}[ERROR]${NC:-} $1" >&2; }

# Status printing functions
print_section() { echo -e "\n${BLUE:-}=== $1 ===${NC:-}"; }

# Exit codes
EXIT_SUCCESS=0
EXIT_FAILURE=1

log_info "Setting up CI/CD tools and pre-commit hooks..."
print_section "CI/CD Setup"

# Check if we're in the dotfiles repository
if [[ ! -f ".chezmoi.toml" ]]; then
    log_error "This script must be run from the dotfiles repository root"
    exit "$EXIT_FAILURE"
fi

# Install pre-commit
print_subsection "Pre-commit Hooks"
if command -v pre-commit &> /dev/null; then
    print_status "OK" "pre-commit is already installed"
else
    print_status "INFO" "Installing pre-commit..."
    if command -v pip3 &> /dev/null; then
        pip3 install pre-commit
    elif command -v pip &> /dev/null; then
        pip install pre-commit
    elif command -v brew &> /dev/null; then
        brew install pre-commit
    else
        log_error "No package manager found to install pre-commit"
        exit "$EXIT_MISSING_DEPENDENCY"
    fi
    print_status "OK" "pre-commit installed successfully"
fi

# Install pre-commit hooks
if [[ -f ".pre-commit-config.yaml" ]]; then
    print_status "INFO" "Installing pre-commit hooks..."
    pre-commit install
    print_status "OK" "Pre-commit hooks installed"
else
    print_status "WARN" ".pre-commit-config.yaml not found"
fi

# Install shellcheck
print_subsection "ShellCheck"
if command -v shellcheck &> /dev/null; then
    print_status "OK" "shellcheck is already installed"
else
    print_status "INFO" "Installing shellcheck..."
    if command -v brew &> /dev/null; then
        brew install shellcheck
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y shellcheck
    else
        log_error "No package manager found to install shellcheck"
        exit "$EXIT_MISSING_DEPENDENCY"
    fi
    print_status "OK" "shellcheck installed successfully"
fi

# Install Python tools
print_subsection "Python Tools"
if command -v black &> /dev/null; then
    print_status "OK" "black is already installed"
else
    print_status "INFO" "Installing black..."
    if command -v pip3 &> /dev/null; then
        pip3 install black
    elif command -v pip &> /dev/null; then
        pip install black
    else
        log_error "No Python package manager found to install black"
        exit "$EXIT_MISSING_DEPENDENCY"
    fi
    print_status "OK" "black installed successfully"
fi

# Install Node.js tools
print_subsection "Node.js Tools"
if command -v prettier &> /dev/null; then
    print_status "OK" "prettier is already installed"
else
    print_status "INFO" "Installing prettier..."
    if command -v npm &> /dev/null; then
        npm install -g prettier
    elif command -v pnpm &> /dev/null; then
        pnpm add -g prettier
    else
        log_error "No Node.js package manager found to install prettier"
        exit "$EXIT_MISSING_DEPENDENCY"
    fi
    print_status "OK" "prettier installed successfully"
fi

# Test the setup
print_subsection "Testing Setup"
print_status "INFO" "Running pre-commit on all files..."
if pre-commit run --all-files; then
    print_status "OK" "Pre-commit hooks working correctly"
else
    print_status "WARN" "Some pre-commit hooks failed (this is normal for initial setup)"
fi

# Test shellcheck
print_status "INFO" "Testing shellcheck..."
if find scripts/ -name "*.sh" -exec shellcheck {} \; 2>/dev/null; then
    print_status "OK" "ShellCheck passed"
else
    print_status "WARN" "ShellCheck found some issues (check output above)"
fi

log_success "CI/CD setup complete!"
echo ""
echo "Next steps:"
echo "  1. Commit your changes: git add . && git commit -m 'feat: add CI/CD setup'"
echo "  2. Push to trigger GitHub Actions: git push"
echo "  3. Check the Actions tab in your GitHub repository"
echo ""
echo "Happy coding! "
