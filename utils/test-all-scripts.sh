#!/usr/bin/env bash

# Test All Scripts - Comprehensive Script Testing

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
WORKING=0
SEGFAULTS=0
ERRORS=0
TOTAL=0

echo "=== Testing All Dotfiles Scripts ==="
echo ""

# Test function
test_script() {
    local script="$1"
    local name
    name=$(basename "$script")

    echo -n "Testing $name... "
    ((TOTAL++))

    # Run script with timeout and capture exit code
    timeout 10s bash "$script" --help >/dev/null 2>&1
    local exit_code=$?

    case $exit_code in
        0)
            echo -e "${GREEN}+ WORKING${NC}"
            ((WORKING++))
            ;;
        124)
            echo -e "${YELLOW}! TIMEOUT${NC}"
            ((ERRORS++))
            ;;
        139)
            echo -e "${RED}x SEGFAULT${NC}"
            ((SEGFAULTS++))
            ;;
        *)
            echo -e "${YELLOW}! ERROR (exit $exit_code)${NC}"
            ((ERRORS++))
            ;;
    esac
}

# Test setup scripts
echo -e "${BLUE}Setup Scripts:${NC}"
echo "---------------"
for script in scripts/setup/*.sh; do
    [ -f "$script" ] && test_script "$script"
done

echo ""
echo -e "${BLUE}Install Scripts:${NC}"
echo "----------------"
for script in scripts/install/*.sh; do
    [ -f "$script" ] && test_script "$script"
done

echo ""
echo -e "${BLUE}Utility Scripts:${NC}"
echo "----------------"
for script in scripts/utils/*.sh; do
    [ -f "$script" ] && test_script "$script"
done

echo ""
echo -e "${BLUE}Template Scripts:${NC}"
echo "-----------------"
for script in scripts/utils/templates/*.sh; do
    [ -f "$script" ] && test_script "$script"
done

echo ""
echo -e "${BLUE}Working Utility Scripts:${NC}"
echo "------------------------"
for script in utils/*.sh; do
    [ -f "$script" ] && test_script "$script"
done

echo ""
echo "=================================="
echo "Script Testing Summary"
echo "=================================="
echo -e "${GREEN}Working: $WORKING${NC}"
echo -e "${RED}Segfaults: $SEGFAULTS${NC}"
echo -e "${YELLOW}Errors/Timeouts: $ERRORS${NC}"
echo -e "${BLUE}Total: $TOTAL${NC}"
echo ""

# Calculate percentage
if [ $TOTAL -gt 0 ]; then
    success_rate=$(( (WORKING * 100) / TOTAL ))
    echo "Success rate: ${success_rate}%"

    if [ $SEGFAULTS -gt 0 ]; then
        echo ""
        echo -e "${RED}Scripts with segfaults need the working alternatives in utils/${NC}"
    fi

    if [ $WORKING -eq $TOTAL ]; then
        echo -e "${GREEN}All scripts working!${NC}"
        exit 0
    else
        echo -e "${YELLOW}Some scripts need attention${NC}"
        exit 1
    fi
fi
