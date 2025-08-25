#!/bin/bash

# Common utilities loader for dotfiles scripts
# This file sources all commonly needed utilities in the correct order

# Get the directory of this script
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities in order of dependency
# 1. Constants (defines variables used by other scripts)
[ -f "$UTILS_DIR/constants.sh" ] && source "$UTILS_DIR/constants.sh"

# 2. Colors (provides color definitions and functions)
[ -f "$UTILS_DIR/colors.sh" ] && source "$UTILS_DIR/colors.sh"

# 3. Platform detection (OS, architecture, package managers)
[ -f "$UTILS_DIR/platform.sh" ] && source "$UTILS_DIR/platform.sh"

# 4. Helper functions (logging, validation, etc.)
[ -f "$UTILS_DIR/helpers.sh" ] && source "$UTILS_DIR/helpers.sh"

# Export that common utilities have been loaded
export COMMON_UTILS_LOADED=true