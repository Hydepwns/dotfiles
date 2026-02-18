#!/bin/bash
# Theme Generator - Generate tool configs from unified theme source
# Reads config/theme/synthwave84.toml and generates configs for all tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
THEME_FILE="$DOTFILES_ROOT/config/theme/synthwave84.toml"

# Source centralized logging
# shellcheck source=logging.sh
source "$SCRIPT_DIR/logging.sh"

# Parse TOML value (simple parser for our use case)
get_toml_value() {
    local key="$1"
    grep "^${key} = " "$THEME_FILE" | sed 's/.*= "//' | sed 's/".*//'
}

# Get all ANSI colors
get_ansi_colors() {
    local prefix="$1"
    local colors=(
        "$(get_toml_value "${prefix}black")"
        "$(get_toml_value "${prefix}red")"
        "$(get_toml_value "${prefix}green")"
        "$(get_toml_value "${prefix}yellow")"
        "$(get_toml_value "${prefix}blue")"
        "$(get_toml_value "${prefix}magenta")"
        "$(get_toml_value "${prefix}cyan")"
        "$(get_toml_value "${prefix}white")"
    )
    echo "${colors[@]}"
}

# Generate Ghostty config
generate_ghostty() {
    local output="$DOTFILES_ROOT/config/ghostty/theme-synthwave84.conf"
    info "Generating Ghostty theme..."

    cat > "$output" << EOF
# Synthwave84 Theme for Ghostty
# Auto-generated from config/theme/synthwave84.toml

background = $(get_toml_value "background")
foreground = $(get_toml_value "foreground")
cursor-color = $(get_toml_value "cursor")
selection-background = $(get_toml_value "selection_bg")
selection-foreground = $(get_toml_value "selection_fg")

# Normal colors (0-7)
palette = 0=$(get_toml_value "black")
palette = 1=$(get_toml_value "red")
palette = 2=$(get_toml_value "green")
palette = 3=$(get_toml_value "yellow")
palette = 4=$(get_toml_value "blue")
palette = 5=$(get_toml_value "magenta")
palette = 6=$(get_toml_value "cyan")
palette = 7=$(get_toml_value "white")

# Bright colors (8-15)
palette = 8=$(get_toml_value "bright_black")
palette = 9=$(get_toml_value "bright_red")
palette = 10=$(get_toml_value "bright_green")
palette = 11=$(get_toml_value "bright_yellow")
palette = 12=$(get_toml_value "bright_blue")
palette = 13=$(get_toml_value "bright_magenta")
palette = 14=$(get_toml_value "bright_cyan")
palette = 15=$(get_toml_value "bright_white")
EOF

    success "Generated: $output"
}

# Generate CSS variables (for web projects)
generate_css() {
    local output="$DOTFILES_ROOT/config/theme/synthwave84.css"
    info "Generating CSS variables..."

    cat > "$output" << EOF
/* Synthwave84 Theme - CSS Variables
 * Auto-generated from config/theme/synthwave84.toml
 */

:root {
  /* Primary */
  --sw84-bg: $(get_toml_value "background");
  --sw84-bg-dark: $(get_toml_value "background_dark");
  --sw84-bg-light: $(get_toml_value "background_light");
  --sw84-fg: $(get_toml_value "foreground");
  --sw84-fg-dim: $(get_toml_value "foreground_dim");

  /* Accent */
  --sw84-accent: $(get_toml_value "accent");
  --sw84-accent-secondary: $(get_toml_value "accent_secondary");

  /* ANSI */
  --sw84-black: $(get_toml_value "black");
  --sw84-red: $(get_toml_value "red");
  --sw84-green: $(get_toml_value "green");
  --sw84-yellow: $(get_toml_value "yellow");
  --sw84-blue: $(get_toml_value "blue");
  --sw84-magenta: $(get_toml_value "magenta");
  --sw84-cyan: $(get_toml_value "cyan");
  --sw84-white: $(get_toml_value "white");

  /* Status */
  --sw84-error: $(get_toml_value "error");
  --sw84-warning: $(get_toml_value "warning");
  --sw84-success: $(get_toml_value "success");
  --sw84-info: $(get_toml_value "info");
}
EOF

    success "Generated: $output"
}

# Generate shell colors export
generate_shell() {
    local output="$DOTFILES_ROOT/config/theme/synthwave84.sh"
    info "Generating shell colors..."

    cat > "$output" << 'HEADER'
#!/bin/bash
# Synthwave84 Theme - Shell Colors
# Auto-generated from config/theme/synthwave84.toml
# Source this file to get theme colors as variables

HEADER

    cat >> "$output" << EOF
# Primary
export SW84_BG="$(get_toml_value "background")"
export SW84_BG_DARK="$(get_toml_value "background_dark")"
export SW84_FG="$(get_toml_value "foreground")"

# Accent
export SW84_ACCENT="$(get_toml_value "accent")"
export SW84_CYAN="$(get_toml_value "cyan")"

# ANSI
export SW84_BLACK="$(get_toml_value "black")"
export SW84_RED="$(get_toml_value "red")"
export SW84_GREEN="$(get_toml_value "green")"
export SW84_YELLOW="$(get_toml_value "yellow")"
export SW84_BLUE="$(get_toml_value "blue")"
export SW84_MAGENTA="$(get_toml_value "magenta")"
export SW84_WHITE="$(get_toml_value "white")"
EOF

    success "Generated: $output"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Generate tool configs from unified Synthwave84 theme

Commands:
    all         Generate all configs (default)
    ghostty     Generate Ghostty theme
    css         Generate CSS variables
    shell       Generate shell color exports
    list        List available generators
    help        Show this help

Theme source: config/theme/synthwave84.toml

EOF
}

# Main
main() {
    if [[ ! -f "$THEME_FILE" ]]; then
        echo "Error: Theme file not found: $THEME_FILE"
        exit 1
    fi

    case "${1:-all}" in
        all)
            generate_ghostty
            generate_css
            generate_shell
            echo ""
            success "All themes generated!"
            ;;
        ghostty) generate_ghostty ;;
        css) generate_css ;;
        shell) generate_shell ;;
        list)
            echo "Available generators:"
            echo "  ghostty, css, shell"
            ;;
        help|--help|-h) show_usage ;;
        *)
            echo "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
