#!/bin/bash
# Tool version management script for DROO's dotfiles
# This script helps manage and update tool versions in .tool-versions

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

# Function to get current version of a tool
get_tool_version() {
    local tool="$1"
    local version=""

    case "$tool" in
        "nodejs")
            if command -v node &> /dev/null; then
                version=$(node --version | sed 's/v//')
            fi
            ;;
        "npm")
            if command -v npm &> /dev/null; then
                version=$(npm --version)
            fi
            ;;
        "yarn")
            if command -v yarn &> /dev/null; then
                version=$(yarn --version)
            fi
            ;;
        "pnpm")
            if command -v pnpm &> /dev/null; then
                version=$(pnpm --version)
            fi
            ;;
        "python")
            if command -v python3 &> /dev/null; then
                version=$(python3 --version 2>&1 | awk '{print $2}')
            fi
            ;;
        "pip")
            if command -v pip3 &> /dev/null; then
                version=$(pip3 --version | awk '{print $2}' | sed 's/(.*)//')
            fi
            ;;
        "ruby")
            if command -v ruby &> /dev/null; then
                version=$(ruby --version | awk '{print $2}' | sed 's/p.*//')
            fi
            ;;
        "bundler")
            if command -v bundle &> /dev/null; then
                version=$(bundle --version 2>&1 | tail -n1 | sed 's/Bundler version //')
            fi
            ;;
        "elixir")
            if command -v elixir &> /dev/null; then
                version=$(elixir --version | head -n1 | awk '{print $2}')
            fi
            ;;
        "erlang")
            if command -v erl &> /dev/null; then
                version=$(erl -eval 'erlang:display(erlang:system_info(version)), halt().' -noshell 2>/dev/null | tr -d '"')
            fi
            ;;
        "mix")
            if command -v mix &> /dev/null; then
                version=$(mix --version | head -n1 | awk '{print $2}')
            fi
            ;;
        "rust")
            if command -v rustc &> /dev/null; then
                version=$(rustc --version | awk '{print $2}')
            fi
            ;;
        "cargo")
            if command -v cargo &> /dev/null; then
                version=$(cargo --version | awk '{print $2}')
            fi
            ;;
        "golang")
            if command -v go &> /dev/null; then
                version=$(go version | awk '{print $3}' | sed 's/go//')
            fi
            ;;
        "lua")
            if command -v lua &> /dev/null; then
                version=$(lua -v 2>&1 | awk '{print $2}')
            fi
            ;;
        "luarocks")
            if command -v luarocks &> /dev/null; then
                version=$(luarocks --version | head -n1 | awk '{print $2}')
            elif command -v /usr/local/bin/luarocks &> /dev/null; then
                version=$(/usr/local/bin/luarocks --version | head -n1 | awk '{print $2}')
            elif command -v /opt/homebrew/bin/luarocks &> /dev/null; then
                version=$(/opt/homebrew/bin/luarocks --version | head -n1 | awk '{print $2}')
            fi
            ;;
        "direnv")
            if command -v direnv &> /dev/null; then
                version=$(direnv --version | awk '{print $1}')
            elif command -v ~/.asdf/shims/direnv &> /dev/null; then
                version=$(~/.asdf/shims/direnv --version | awk '{print $1}')
            elif command -v "$HOME/.asdf/shims/direnv" &> /dev/null; then
                version=$("$HOME/.asdf/shims/direnv" --version | awk '{print $1}')
            fi
            ;;
        "devenv")
            if command -v devenv &> /dev/null; then
                version=$(devenv --version | awk '{print $2}')
            elif nix profile list | grep -q devenv; then
                version="1.8.0"
            fi
            ;;
        "asdf")
            if command -v asdf &> /dev/null; then
                version=$(asdf --version | awk '{print $2}')
            fi
            ;;
        "foundry")
            if command -v forge &> /dev/null; then
                version=$(forge --version | awk '{print $2}')
            fi
            ;;
        "solana")
            if command -v solana &> /dev/null; then
                version=$(solana --version | awk '{print $2}')
            fi
            ;;
        "anchor")
            if command -v anchor &> /dev/null; then
                version=$(anchor --version | awk '{print $2}')
            elif command -v ~/.avm/bin/anchor &> /dev/null; then
                version=$(~/.avm/bin/anchor --version | awk '{print $2}')
            elif command -v "$HOME/.avm/bin/anchor" &> /dev/null; then
                version=$("$HOME/.avm/bin/anchor" --version | awk '{print $2}')
            fi
            ;;
        "postgresql")
            if command -v psql &> /dev/null; then
                version=$(psql --version | awk '{print $3}' | sed 's/,.*//')
            fi
            ;;
        "cmake")
            if command -v cmake &> /dev/null; then
                version=$(cmake --version | head -n1 | awk '{print $3}')
            fi
            ;;
        "make")
            if command -v make &> /dev/null; then
                version=$(make --version | head -n1 | awk '{print $3}')
            fi
            ;;
        "git")
            if command -v git &> /dev/null; then
                version=$(git --version | awk '{print $3}')
            fi
            ;;
        "zsh")
            if command -v zsh &> /dev/null; then
                version=$(zsh --version | awk '{print $2}')
            fi
            ;;
        "neovim")
            if command -v nvim &> /dev/null; then
                version=$(nvim --version | head -n1 | awk '{print $2}' | sed 's/v//')
            fi
            ;;
        "zed")
            if command -v zed &> /dev/null; then
                version=$(zed --version 2>/dev/null | awk '{print $2}' | sed 's/–.*//' || echo "unknown")
            fi
            ;;
        "brew")
            if command -v brew &> /dev/null; then
                version=$(brew --version | head -n1 | awk '{print $2}')
            fi
            ;;
    esac

    echo "$version"
}

# Function to update .tool-versions file
update_tool_versions() {
    local tool_versions_file="$HOME/.tool-versions"
    local temp_file
    temp_file="$(mktemp)"

    print_status "INFO" "Updating .tool-versions file..."

    # Read current .tool-versions and update versions
    if [[ -f "$tool_versions_file" ]]; then
        while IFS= read -r line; do
            # Skip comments and empty lines
            if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
                echo "$line" >> "$temp_file"
                continue
            fi

            # Extract tool name
            local tool
            tool="$(echo "$line" | awk '{print $1}')"
            local current_version
            current_version="$(get_tool_version "$tool")"

            if [[ -n "$current_version" ]]; then
                echo "$tool $current_version" >> "$temp_file"
                print_status "OK" "Updated $tool to $current_version"
            else
                echo "$line" >> "$temp_file"
                print_status "WARN" "Could not detect version for $tool"
            fi
        done < "$tool_versions_file"
    else
        print_status "ERROR" ".tool-versions file not found"
        return 1
    fi

    # Replace original file
    mv "$temp_file" "$tool_versions_file"
    print_status "OK" ".tool-versions file updated successfully"
}

# Function to check for outdated tools
check_outdated_tools() {
    print_status "INFO" "Checking for outdated tools..."

    local tool_versions_file="$HOME/.tool-versions"

    if [[ ! -f "$tool_versions_file" ]]; then
        print_status "ERROR" ".tool-versions file not found"
        return 1
    fi

    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
            continue
        fi

        local tool
        tool="$(echo "$line" | awk '{print $1}')"
        local specified_version
        specified_version="$(echo "$line" | awk '{print $2}')"
        local current_version
        current_version="$(get_tool_version "$tool")"

        if [[ -n "$current_version" && "$current_version" != "$specified_version" ]]; then
            print_status "WARN" "$tool: specified $specified_version, installed $current_version"
        elif [[ -n "$current_version" ]]; then
            print_status "OK" "$tool: $current_version (up to date)"
        else
            print_status "ERROR" "$tool: not installed"
        fi
    done < "$tool_versions_file"
}

# Function to install missing tools
install_missing_tools() {
    print_status "INFO" "Installing missing tools..."

    local tool_versions_file="$HOME/.tool-versions"

    if [[ ! -f "$tool_versions_file" ]]; then
        print_status "ERROR" ".tool-versions file not found"
        return 1
    fi

    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
            continue
        fi

        local tool
        tool="$(echo "$line" | awk '{print $1}')"
        local version
        version="$(echo "$line" | awk '{print $2}')"

        if ! command -v "$tool" &> /dev/null; then
            print_status "INFO" "Installing $tool $version..."

            if command -v asdf &> /dev/null; then
                asdf plugin add "$tool" 2>/dev/null || true
                asdf install "$tool" "$version"
                asdf local "$tool" "$version"
            else
                print_status "WARN" "asdf not found, please install $tool manually"
            fi
        fi
    done < "$tool_versions_file"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  update     - Update .tool-versions with current installed versions"
    echo "  check      - Check for outdated tools"
    echo "  install    - Install missing tools using asdf"
    echo "  list       - List all tools and their versions"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 update    # Update .tool-versions file"
    echo "  $0 check     # Check for outdated tools"
    echo "  $0 install   # Install missing tools"
}

# Function to list all tools
list_tools() {
    print_status "INFO" "Listing all tools and their versions..."

    local tool_versions_file="$HOME/.tool-versions"

    if [[ ! -f "$tool_versions_file" ]]; then
        print_status "ERROR" ".tool-versions file not found"
        return 1
    fi

    echo ""
    echo "Tool Versions:"
    echo "=============="

    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
            if [[ "$line" =~ ^[[:space:]]*# ]]; then
                echo ""
                echo "$line"
            fi
            continue
        fi

        local tool
        tool="$(echo "$line" | awk '{print $1}')"
        local specified_version
        specified_version="$(echo "$line" | awk '{print $2}')"
        local current_version
        current_version="$(get_tool_version "$tool")"

        if [[ -n "$current_version" ]]; then
            if [[ "$current_version" == "$specified_version" ]]; then
                echo -e "  ${GREEN}✓${NC} $tool: $current_version"
            else
                echo -e "  ${YELLOW}⚠${NC} $tool: specified $specified_version, installed $current_version"
            fi
        else
            echo -e "  ${RED}✗${NC} $tool: not installed (specified $specified_version)"
        fi
    done < "$tool_versions_file"
}

# Main function
main() {
    local command="${1:-help}"

    case "$command" in
        "update")
            update_tool_versions
            ;;
        "check")
            check_outdated_tools
            ;;
        "install")
            install_missing_tools
            ;;
        "list")
            list_tools
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            print_status "ERROR" "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
