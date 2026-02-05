# shellcheck disable=all
# Module loader for DROO's dotfiles
# This file sources all modular zsh configuration files

# Get the directory where this script is located
ZSH_MODULES_DIR="${0:A:h}"

# Source modular configuration files
if [[ -d "$ZSH_MODULES_DIR" ]]; then
    # Source core modules first (paths, tools, etc.)
    if [[ -d "$ZSH_MODULES_DIR/core" ]]; then
        for core_file in "$ZSH_MODULES_DIR"/core/*.zsh; do
            if [[ -f "$core_file" ]]; then
                source "$core_file"
            fi
        done
    fi

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

    # Source root-level env (explicit, no wildcard to avoid stale files)
    [[ -f "$ZSH_MODULES_DIR/env.zsh" ]] && source "$ZSH_MODULES_DIR/env.zsh"
fi
