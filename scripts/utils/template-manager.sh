#!/opt/homebrew/bin/bash
# Template management system for DROO's dotfiles

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/templates/common.sh"

# Template registry with metadata
declare -A TEMPLATES=(
    ["web3"]="ethereum,solana,foundry,huff:Web3 smart contract development"
    ["nextjs"]="typescript,tailwind,eslint:Next.js with TypeScript and Tailwind"
    ["react"]="typescript,vite,eslint:React with TypeScript and Vite"
    ["rust"]="cargo,clippy,rustfmt:Rust project with common dependencies"
    ["elixir"]="mix,phoenix,exunit:Elixir Phoenix project"
    ["node"]="typescript,jest,eslint:Node.js project with TypeScript"
    ["python"]="poetry,pytest,black:Python project with virtual environment"
    ["go"]="modules,test,go-mod:Go project with modules"
)

# Template features registry
# shellcheck disable=SC2034
declare -A TEMPLATE_FEATURES=(
    ["web3"]="ethereum,solana,foundry,huff,hardhat,anchor"
    ["nextjs"]="typescript,tailwind,eslint,prettier,jest,storybook"
    ["react"]="typescript,vite,eslint,prettier,jest,testing-library"
    ["rust"]="cargo,clippy,rustfmt,tokio,serde,axum"
    ["elixir"]="mix,phoenix,exunit,credo,ex_doc,ecto"
    ["node"]="typescript,jest,eslint,prettier,nodemon,ts-node"
    ["python"]="poetry,pytest,black,flake8,mypy,fastapi"
    ["go"]="modules,test,go-mod,gin,viper,cobra"
)

# Function to generate project template
generate_template() {
    local type="$1"
    local name="$2"
    shift 2
    local features=("$@")
    
    # Validate inputs
    if ! validate_project_name "$name"; then
        return 1
    fi
    
    if ! check_project_exists "$name"; then
        return 1
    fi
    
    # Validate template type
    if [[ ! -v TEMPLATES[$type] ]]; then
        print_error "Unknown template type: $type"
        echo "Available templates: ${!TEMPLATES[*]}"
        return 1
    fi
    
    # Source template-specific modules
    # shellcheck disable=SC1091
    case "$type" in
        "web3")
            source "$SCRIPT_DIR/templates/web3.sh"
            ;;
        "nextjs")
            source "$SCRIPT_DIR/templates/nextjs.sh"
            ;;
        "rust")
            source "$SCRIPT_DIR/templates/rust.sh"
            ;;
        *)
            print_error "Template generation not implemented for: $type"
            return 1
            ;;
    esac
    
    # Create project structure
    create_basic_structure "$name"
    
    # Generate based on type
    local features_str="${features[*]}"
    if [[ "$type" == "web3" ]]; then
        generate_web3_project "$name" "$features_str"
    elif [[ "$type" == "nextjs" ]]; then
        generate_nextjs_project "$name" "$features_str"
    elif [[ "$type" == "rust" ]]; then
        generate_rust_project "$name" "$features_str"
    else
        print_error "Template generation not implemented for: $type"
        return 1
    fi
    
    print_success "$name"
}







# Function to list available templates
list_templates() {
    echo "Available templates:"
    for template in "${!TEMPLATES[@]}"; do
        local info="${TEMPLATES[$template]}"
        local features_str
        features_str="${info%%:*}"
        local description="${info##*:}"
        echo "  $template: $description"
        echo "    Features: $features_str"
    done
}

# Function to show template help
show_template_help() {
    echo "Template generator for DROO's dotfiles"
    echo "Usage: $0 <template-type> <project-name> [features...]"
    echo ""
    list_templates
    echo ""
    echo "Examples:"
    echo "  $0 web3 my-defi-project ethereum solana"
    echo "  $0 nextjs my-webapp typescript tailwind jest"
    echo "  $0 rust my-cli-tool"
}

# Main function
main() {
    local template_type="$1"
    local project_name="$2"
    shift 2
    local features=("$@")
    
    # Show help if no arguments
    if [[ -z "$template_type" ]]; then
        show_template_help
        exit 0
    fi
    
    # Validate arguments
    if [[ -z "$project_name" ]]; then
        print_error "Project name is required"
        show_template_help
        exit 1
    fi
    
    # Generate template
    if generate_template "$template_type" "$project_name" "${features[@]}"; then
        print_success "$project_name"
    else
        print_error "Failed to generate template"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 