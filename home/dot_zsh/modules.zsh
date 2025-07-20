# shellcheck disable=all
# Module loader for DROO's dotfiles
# This file sources all modular zsh configuration files

# Get the directory where this script is located
ZSH_MODULES_DIR="${0:A:h}"

# Source modular configuration files
if [[ -d "$ZSH_MODULES_DIR" ]]; then
    # Source aliases
    if [[ -d "$ZSH_MODULES_DIR/aliases" ]]; then
        for alias_file in "$ZSH_MODULES_DIR"/aliases/*.zsh; do
            if [[ -f "$alias_file" ]]; then
                source "$alias_file"
            fi
        done
    fi

    # Source functions
    if [[ -d "$ZSH_MODULES_DIR/functions" ]]; then
        for func_file in "$ZSH_MODULES_DIR"/functions/*.zsh; do
            if [[ -f "$func_file" ]]; then
                source "$func_file"
            fi
        done
    fi

    # Source other modular files
    for module_file in "$ZSH_MODULES_DIR"/*.zsh; do
        if [[ -f "$module_file" ]] && [[ "$(basename "$module_file")" != "modules.zsh" ]]; then
            source "$module_file"
        fi
    done
fi
