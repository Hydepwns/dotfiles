#!/bin/bash
# Unified script loading system for DROO's dotfiles

# Script categories with their directories and scripts
declare -A SCRIPT_CATEGORIES=(
    ["setup"]="scripts/setup:bootstrap.sh,quick-setup.sh,setup-github-token.sh"
    ["utils"]="scripts/utils:helpers.sh,colors.sh,platform.sh,health-check.sh,performance-test.sh,process-templates.sh,test-modular-system.sh,check-conflicts.sh,update-tool-versions.sh,make-helpers.sh,script-loader.sh"
    ["templates"]="scripts/templates:generate.sh"
    ["dev"]="scripts/utils:dev-workflow.sh"
)

# Function to load all scripts in a category
load_script_category() {
    local category="$1"
    local script_info="${SCRIPT_CATEGORIES[$category]}"
    
    if [[ -z "$script_info" ]]; then
        echo "Unknown script category: $category"
        return 1
    fi
    
    local script_dir="${script_info%%:*}"
    local scripts="${script_info##*:}"
    
    if [[ -d "$script_dir" ]]; then
        IFS=',' read -ra script_array <<< "$scripts"
        for script in "${script_array[@]}"; do
            local script_path="$script_dir/$script"
            if [[ -f "$script_path" ]]; then
                # shellcheck disable=SC1090
                source "$script_path"
            fi
        done
    fi
}

# Function to list available scripts
list_scripts() {
    echo "Available script categories:"
    for category in "${!SCRIPT_CATEGORIES[@]}"; do
        local script_info="${SCRIPT_CATEGORIES[$category]}"
        local script_dir="${script_info%%:*}"
        local scripts="${script_info##*:}"
        echo "  $category: $scripts"
    done
}

# Function to run a specific script
run_script() {
    local category="$1"
    local script_name="$2"
    local args="$3"
    
    local script_info="${SCRIPT_CATEGORIES[$category]}"
    if [[ -z "$script_info" ]]; then
        echo "Unknown script category: $category"
        return 1
    fi
    
    local script_dir="${script_info%%:*}"
    local script_path="$script_dir/$script_name"
    
    if [[ -f "$script_path" ]]; then
        chmod +x "$script_path"
        ./"$script_path" "$args"
    else
        echo "Script not found: $script_path"
        return 1
    fi
}

# Function to check if a script exists
script_exists() {
    local category="$1"
    local script_name="$2"
    
    local script_info="${SCRIPT_CATEGORIES[$category]}"
    if [[ -z "$script_info" ]]; then
        return 1
    fi
    
    local script_dir="${script_info%%:*}"
    local script_path="$script_dir/$script_name"
    
    [[ -f "$script_path" ]]
}

# Function to get script path
get_script_path() {
    local category="$1"
    local script_name="$2"
    
    local script_info="${SCRIPT_CATEGORIES[$category]}"
    if [[ -z "$script_info" ]]; then
        return 1
    fi
    
    local script_dir="${script_info%%:*}"
    echo "$script_dir/$script_name"
}

# Function to validate script dependencies
validate_script_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    local required_commands=("chezmoi" "git" "zsh")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check for required directories
    local required_dirs=("scripts" "home" "config")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            missing_deps+=("$dir")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# Function to initialize script environment
init_script_env() {
    # Set script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
    
    # Export variables
    export SCRIPT_DIR
    export DOTFILES_ROOT
    
    # Load common utilities
    if [[ -f "$SCRIPT_DIR/helpers.sh" ]]; then
        # shellcheck disable=SC1091
        source "$SCRIPT_DIR/helpers.sh"
    fi
    
    if [[ -f "$SCRIPT_DIR/colors.sh" ]]; then
        # shellcheck disable=SC1091
        source "$SCRIPT_DIR/colors.sh"
    fi
    
    if [[ -f "$SCRIPT_DIR/platform.sh" ]]; then
        # shellcheck disable=SC1091
        source "$SCRIPT_DIR/platform.sh"
    fi
}

# Auto-initialize when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    case "${1:-}" in
        "list")
            list_scripts
            ;;
        "load")
            if [[ -n "$2" ]]; then
                load_script_category "$2"
            else
                echo "Usage: $0 load <category>"
                exit 1
            fi
            ;;
        "run")
            if [[ -n "$2" && -n "$3" ]]; then
                run_script "$2" "$3" "${4:-}"
            else
                echo "Usage: $0 run <category> <script> [args...]"
                exit 1
            fi
            ;;
        "validate")
            validate_script_dependencies
            ;;
        *)
            echo "Usage: $0 {list|load|run|validate}"
            echo ""
            echo "Commands:"
            echo "  list     - List available script categories"
            echo "  load     - Load all scripts in a category"
            echo "  run      - Run a specific script"
            echo "  validate - Validate script dependencies"
            exit 1
            ;;
    esac
else
    # Script is being sourced
    init_script_env
fi 