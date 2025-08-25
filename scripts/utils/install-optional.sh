#!/usr/bin/env bash

# Use simple script initialization (no segfaults!)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/simple-init.sh"

# Install optional tools utility for DROO's dotfiles

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
command_exists() { command -v "$1" >/dev/null 2>&1; }
validate_args() {
    local min_args="$1"
    shift
    local provided_args=("$@")
    [[ ${#provided_args[@]} -ge $min_args ]]
}

# Optional tools registry (using functions for compatibility)
get_optional_tool_description() {
    local tool="$1"
    case "$tool" in
        "neovim") echo "Neovim - Vim-fork focused on extensibility and usability" ;;
        "elixir") echo "Elixir - Dynamic, functional language for scalable applications" ;;
        "lua") echo "Lua - Lightweight, high-level programming language" ;;
        "direnv") echo "direnv - Unclutter your .profile" ;;
        "asdf") echo "asdf - Extendable version manager" ;;
        "rbenv") echo "rbenv - Ruby version manager" ;;
        "pyenv") echo "pyenv - Python version manager" ;;
        "nvm") echo "NVM - Node Version Manager" ;;
        "rustup") echo "Rustup - Rust toolchain installer" ;;
        "go") echo "Go - Programming language" ;;
        *) echo "" ;;
    esac
}

# Package manager commands (using functions for compatibility)
get_package_manager_for_platform() {
    local platform="$1"
    case "$platform" in
        "macos") echo "brew" ;;
        "linux") echo "apt" ;;
        "nix") echo "nix-env" ;;
        *) echo "" ;;
    esac
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    --list              List all optional tools
    --install <tool>    Install specific tool
    --all               Install all optional tools
    --interactive       Interactive installation (default)

Examples:
    $0 --list
    $0 --install neovim
    $0 --all
    $0 --interactive

EOF
}

# Function to get package manager
get_package_manager() {
    case "$PLATFORM" in
        "darwin")
            if command_exists "brew"; then
                echo "brew"
            else
                echo ""
            fi
            ;;
        "linux")
            if command_exists "apt"; then
                echo "apt"
            elif command_exists "yum"; then
                echo "yum"
            elif command_exists "dnf"; then
                echo "dnf"
            else
                echo ""
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to list optional tools
list_optional_tools() {
    log_info "Available optional tools:"
    echo

    local tools=("neovim" "elixir" "lua" "direnv" "asdf" "rbenv" "pyenv" "nvm" "rustup" "go")

    for tool in "${tools[@]}"; do
        local description
        description=$(get_optional_tool_description "$tool")
        local status=""

        if command_exists "$tool"; then
            status="[OK]"
        else
            status="[FAIL]"
        fi

        printf "  %-15s %s %s\n" "$tool" "$status" "$description"
    done
    echo
}

# Function to install tool
install_tool() {
    local tool="$1"
    local package_manager="$2"
    local description

    description=$(get_optional_tool_description "$tool")
    if [[ -z "$description" ]]; then
        log_error "Unknown tool: $tool"
        return $EXIT_INVALID_ARGS
    fi

    if command_exists "$tool"; then
        log_warning "$tool is already installed"
        return $EXIT_SUCCESS
    fi

    log_info "Installing $tool..."

    case "$package_manager" in
        "brew")
            if brew install "$tool"; then
                log_success "$tool installed successfully"
                return $EXIT_SUCCESS
            else
                log_error "Failed to install $tool"
                return $EXIT_FAILURE
            fi
            ;;
        "apt")
            if sudo apt update && sudo apt install -y "$tool"; then
                log_success "$tool installed successfully"
                return $EXIT_SUCCESS
            else
                log_error "Failed to install $tool"
                return $EXIT_FAILURE
            fi
            ;;
        "yum")
            if sudo yum install -y "$tool"; then
                log_success "$tool installed successfully"
                return $EXIT_SUCCESS
            else
                log_error "Failed to install $tool"
                return $EXIT_FAILURE
            fi
            ;;
        "dnf")
            if sudo dnf install -y "$tool"; then
                log_success "$tool installed successfully"
                return $EXIT_SUCCESS
            else
                log_error "Failed to install $tool"
                return $EXIT_FAILURE
            fi
            ;;
        *)
            log_error "No supported package manager found"
            return $EXIT_MISSING_DEPENDENCY
            ;;
    esac
}

# Function to install specific tool
install_specific_tool() {
    local tool="$1"
    local package_manager

    package_manager=$(get_package_manager)
    if [[ -z "$package_manager" ]]; then
        log_error "No supported package manager found"
        return $EXIT_MISSING_DEPENDENCY
    fi

    install_tool "$tool" "$package_manager"
}

# Function to install all tools
install_all_tools() {
    local package_manager

    package_manager=$(get_package_manager)
    if [[ -z "$package_manager" ]]; then
        log_error "No supported package manager found"
        return $EXIT_MISSING_DEPENDENCY
    fi

    log_info "Installing all optional tools..."

    local installed_count
    installed_count=0
    local failed_count
    failed_count=0

    local tools=("neovim" "elixir" "lua" "direnv" "asdf" "rbenv" "pyenv" "nvm" "rustup" "go")

    for tool in "${tools[@]}"; do
        if install_tool "$tool" "$package_manager"; then
            ((installed_count++))
        else
            ((failed_count++))
        fi
    done

    log_success "Installation complete: $installed_count installed, $failed_count failed"

    if [[ $failed_count -gt 0 ]]; then
        return $EXIT_FAILURE
    else
        return $EXIT_SUCCESS
    fi
}

# Function to interactive installation
interactive_installation() {
    local package_manager

    package_manager=$(get_package_manager)
    if [[ -z "$package_manager" ]]; then
        log_error "No supported package manager found"
        return $EXIT_MISSING_DEPENDENCY
    fi

    log_info "Interactive optional tools installation"
    echo

    local installed_count
    installed_count=0

    local tools=("neovim" "elixir" "lua" "direnv" "asdf" "rbenv" "pyenv" "nvm" "rustup" "go")

    for tool in "${tools[@]}"; do
        local description
        description=$(get_optional_tool_description "$tool")

        if command_exists "$tool"; then
            log_info "$tool is already installed"
            continue
        fi

        if confirm "Install $tool? ($description)" "n"; then
            if install_tool "$tool" "$package_manager"; then
                ((installed_count++))
            fi
        fi
    done

    log_success "Installation complete: $installed_count tools installed"
}

# Function to check installation status
check_installation_status() {
    log_info "Checking installation status..."

    local installed_count=0
    local tools=("neovim" "elixir" "lua" "direnv" "asdf" "rbenv" "pyenv" "nvm" "rustup" "go")
    local total_count=${#tools[@]}

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            ((installed_count++))
        fi
    done

    log_info "Installed: $installed_count/$total_count optional tools"

    if [[ $installed_count -eq $total_count ]]; then
        log_success "All optional tools are installed"
        return $EXIT_SUCCESS
    else
        log_warning "Some optional tools are not installed"
        return $EXIT_FAILURE
    fi
}

# Main function
main() {
    case "${1:-}" in
        "--list")
            list_optional_tools
            ;;
        "--install")
            if [[ -z "$2" ]]; then
                log_error "Tool name required"
                show_usage
                exit $EXIT_INVALID_ARGS
            fi
            install_specific_tool "$2"
            ;;
        "--all")
            install_all_tools
            ;;
        "--interactive"|"")
            interactive_installation
            ;;
        "--status")
            check_installation_status
            ;;
        "-h"|"--help")
            show_usage
            exit $EXIT_SUCCESS
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit $EXIT_INVALID_ARGS
            ;;
    esac
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
