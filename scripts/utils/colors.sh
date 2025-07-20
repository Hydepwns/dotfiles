#!/bin/bash

# Shared color utilities for dotfiles scripts
# This file provides consistent color output across all scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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
        "DEBUG")
            echo -e "${PURPLE}🔍${NC} $message"
            ;;
    esac
}

# Print section header
print_section() {
    local title="$1"
    echo
    echo -e "${CYAN}=== $title ===${NC}"
    echo
}

# Print subsection header
print_subsection() {
    local title="$1"
    echo -e "${BLUE}--- $title ---${NC}"
} 