#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_INIT_PATH="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1)"
source "$SCRIPT_DIR/${SCRIPT_INIT_PATH#./}"

# Centralized template management for DROO's dotfiles

# Source common utilities
source "$SCRIPT_DIR/helpers.sh"

# Template registry (using functions for compatibility)
get_template_script() {
    local template_type="$1"
    case "$template_type" in
        "web3") echo "scripts/templates/web3.sh" ;;
        "nextjs") echo "scripts/templates/nextjs.sh" ;;
        "react") echo "scripts/templates/react.sh" ;;
        "rust") echo "scripts/templates/rust.sh" ;;
        "elixir") echo "scripts/templates/elixir.sh" ;;
        "node") echo "scripts/templates/node.sh" ;;
        "python") echo "scripts/templates/python.sh" ;;
        "go") echo "scripts/templates/go.sh" ;;
        *) echo "" ;;
    esac
}

# Template descriptions (using functions for compatibility)
get_template_description() {
    local template_type="$1"
    case "$template_type" in
        "web3") echo "Ethereum/Solana smart contract project" ;;
        "nextjs") echo "Next.js with TypeScript and Tailwind" ;;
        "react") echo "React with TypeScript and Vite" ;;
        "rust") echo "Rust project with common dependencies" ;;
        "elixir") echo "Elixir Phoenix project" ;;
        "node") echo "Node.js project with TypeScript" ;;
        "python") echo "Python project with virtual environment" ;;
        "go") echo "Go project with modules" ;;
        *) echo "" ;;
    esac
}

# Template options (using functions for compatibility)
get_template_options() {
    local template_type="$1"
    case "$template_type" in
        "web3") echo "--web3-type <type> --with-tests --with-docs --with-ci" ;;
        "nextjs") echo "--with-tests --with-docs --with-ci --with-auth" ;;
        "react") echo "--with-tests --with-docs --with-ci --with-router" ;;
        "rust") echo "--with-tests --with-docs --with-ci --with-cli" ;;
        "elixir") echo "--with-tests --with-docs --with-ci --with-api" ;;
        "node") echo "--with-tests --with-docs --with-ci --with-express" ;;
        "python") echo "--with-tests --with-docs --with-ci --with-fastapi" ;;
        "go") echo "--with-tests --with-docs --with-ci --with-gin" ;;
        *) echo "" ;;
    esac
}

# Function to list available templates
list_templates() {
    echo "Available templates:"
    echo
    local template_types=("web3" "nextjs" "react" "rust" "elixir" "node" "python" "go")

    for template in "${template_types[@]}"; do
        local description
        description=$(get_template_description "$template")
        local options
        options=$(get_template_options "$template")
        printf "  %-15s - %s\n" "$template" "$description"
        if [[ -n "$options" ]]; then
            printf "    Options: %s\n" "$options"
        fi
        echo
    done
}

# Function to validate template
validate_template() {
    local template_type="$1"
    local template_script

    template_script=$(get_template_script "$template_type")

    if [[ -z "$template_script" ]]; then
        log_error "Unknown template type: $template_type"
        return $EXIT_INVALID_ARGS
    fi

    if [[ ! -f "$template_script" ]]; then
        log_error "Template script not found: $template_script"
        return $EXIT_FILE_NOT_FOUND
    fi

    return $EXIT_SUCCESS
}


# Function to generate template
generate_template() {
    local template_type="$1"
    local project_name="$2"
    local options="$3"

    # Validate template
    if ! validate_template "$template_type"; then
        return $?
    fi

    # Validate project name
    if ! validate_required_args "$project_name"; then
        return $EXIT_INVALID_ARGS
    fi

    local template_script
    template_script=$(get_template_script "$template_type")

    log_info "Generating $template_type template: $project_name"

    # Execute template with common validation
    if [[ -x "$template_script" ]]; then
        "$template_script" "$project_name" "$options"
    else
        chmod +x "$template_script"
        "$template_script" "$project_name" "$options"
    fi

    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        log_success "Template generated successfully: $project_name"
    else
        log_error "Template generation failed"
    fi

    return $exit_code
}

# Function to show template help
show_template_help() {
    local template_type="$1"

    if [[ -n "$template_type" ]]; then
        if ! validate_template "$template_type"; then
            return $?
        fi

        local description
        description=$(get_template_description "$template_type")
        local options
        options=$(get_template_options "$template_type")

        echo "Template: $template_type"
        echo "Description: $description"
        echo "Usage: $0 generate $template_type <project-name> [options]"
        if [[ -n "$options" ]]; then
            echo "Options: $options"
        fi
        echo
        echo "Example: $0 generate $template_type my-project"
    else
        echo "Template generator for DROO's dotfiles"
        echo "Usage: $0 <command> [options]"
        echo
        echo "Commands:"
        echo "  list                    List all available templates"
        echo "  generate <type> <name>  Generate a project template"
        echo "  help <type>             Show help for specific template"
        echo
        echo "Examples:"
        echo "  $0 list"
        echo "  $0 generate web3 my-defi-project"
        echo "  $0 help nextjs"
    fi
}

# Function to parse template options
parse_template_options() {
    local options
    options="$1"
    local parsed_options
    parsed_options=()

    if [[ -n "$options" ]]; then
        IFS=' ' read -ra option_array <<< "$options"
        for option in "${option_array[@]}"; do
            case "$option" in
                --web3-type)
                    parsed_options+=("$option")
                    ;;
                --with-*)
                    parsed_options+=("$option")
                    ;;
                *)
                    log_warning "Unknown option: $option"
                    ;;
            esac
        done
    fi

    echo "${parsed_options[@]}"
}

# Main function
main() {
    case "${1:-}" in
        "list")
            list_templates
            ;;
        "generate")
            if [[ $# -lt 3 ]]; then
                log_error "Usage: $0 generate <type> <name> [options]"
                exit $EXIT_INVALID_ARGS
            fi
            local template_type="$2"
            local project_name="$3"
            local options="${4:-}"
            generate_template "$template_type" "$project_name" "$options"
            ;;
        "help")
            show_template_help "${2:-}"
            ;;
        "validate")
            if [[ $# -lt 2 ]]; then
                log_error "Usage: $0 validate <type>"
                exit $EXIT_INVALID_ARGS
            fi
            validate_template "$2"
            ;;
        *)
            show_template_help
            exit $EXIT_INVALID_ARGS
            ;;
    esac
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
