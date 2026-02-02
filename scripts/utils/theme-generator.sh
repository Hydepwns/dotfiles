#!/bin/bash
# Theme Generator - Generate tool configs from unified theme source
# Reads config/theme/synthwave84.toml and generates configs for all tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
THEME_FILE="$DOTFILES_ROOT/config/theme/synthwave84.toml"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${CYAN}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

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

# Generate Kitty theme
generate_kitty() {
    local output="$DOTFILES_ROOT/config/kitty/synthwave84.conf"
    info "Generating Kitty theme..."

    cat > "$output" << EOF
# Synthwave84 Theme for Kitty
# Auto-generated from config/theme/synthwave84.toml

background $(get_toml_value "background")
foreground $(get_toml_value "foreground")
cursor $(get_toml_value "cursor")
cursor_text_color $(get_toml_value "selection_fg")
selection_background $(get_toml_value "selection_bg")
selection_foreground $(get_toml_value "selection_fg")
url_color $(get_toml_value "cyan")

# Normal colors
color0 $(get_toml_value "black")
color1 $(get_toml_value "red")
color2 $(get_toml_value "green")
color3 $(get_toml_value "yellow")
color4 $(get_toml_value "blue")
color5 $(get_toml_value "magenta")
color6 $(get_toml_value "cyan")
color7 $(get_toml_value "white")

# Bright colors
color8 $(get_toml_value "bright_black")
color9 $(get_toml_value "bright_red")
color10 $(get_toml_value "bright_green")
color11 $(get_toml_value "bright_yellow")
color12 $(get_toml_value "bright_blue")
color13 $(get_toml_value "bright_magenta")
color14 $(get_toml_value "bright_cyan")
color15 $(get_toml_value "bright_white")

# Tab bar
active_tab_background $(get_toml_value "accent")
active_tab_foreground $(get_toml_value "background_dark")
inactive_tab_background $(get_toml_value "background_dark")
inactive_tab_foreground $(get_toml_value "foreground_dim")

# Window borders
active_border_color $(get_toml_value "accent")
inactive_border_color $(get_toml_value "border")
EOF

    success "Generated: $output"
}

# Generate Alacritty theme (if needed)
generate_alacritty() {
    local output="$DOTFILES_ROOT/config/alacritty/synthwave84.toml"
    mkdir -p "$(dirname "$output")"
    info "Generating Alacritty theme..."

    cat > "$output" << EOF
# Synthwave84 Theme for Alacritty
# Auto-generated from config/theme/synthwave84.toml

[colors.primary]
background = "$(get_toml_value "background")"
foreground = "$(get_toml_value "foreground")"

[colors.cursor]
text = "$(get_toml_value "selection_fg")"
cursor = "$(get_toml_value "cursor")"

[colors.selection]
text = "$(get_toml_value "selection_fg")"
background = "$(get_toml_value "selection_bg")"

[colors.normal]
black = "$(get_toml_value "black")"
red = "$(get_toml_value "red")"
green = "$(get_toml_value "green")"
yellow = "$(get_toml_value "yellow")"
blue = "$(get_toml_value "blue")"
magenta = "$(get_toml_value "magenta")"
cyan = "$(get_toml_value "cyan")"
white = "$(get_toml_value "white")"

[colors.bright]
black = "$(get_toml_value "bright_black")"
red = "$(get_toml_value "bright_red")"
green = "$(get_toml_value "bright_green")"
yellow = "$(get_toml_value "bright_yellow")"
blue = "$(get_toml_value "bright_blue")"
magenta = "$(get_toml_value "bright_magenta")"
cyan = "$(get_toml_value "bright_cyan")"
white = "$(get_toml_value "bright_white")"
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
    kitty       Generate Kitty theme
    alacritty   Generate Alacritty theme
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
            generate_kitty
            generate_alacritty
            generate_css
            generate_shell
            echo ""
            success "All themes generated!"
            ;;
        ghostty) generate_ghostty ;;
        kitty) generate_kitty ;;
        alacritty) generate_alacritty ;;
        css) generate_css ;;
        shell) generate_shell ;;
        list)
            echo "Available generators:"
            echo "  ghostty, kitty, alacritty, css, shell"
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
