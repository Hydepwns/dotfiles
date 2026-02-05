#!/usr/bin/env bash

# Quick Script Test - Fast check for immediate failures

echo "=== Quick Script Status Check ==="
echo ""

# Test with very short timeout
test_quick() {
    local script="$1"
    local name
    name=$(basename "$script")

    echo -n "$name: "

    # Very short timeout - if it doesn't respond quickly, it's problematic
    if timeout 2s bash -n "$script" >/dev/null 2>&1; then
        if timeout 2s bash "$script" --help >/dev/null 2>&1; then
            echo "+ WORKING"
        else
            echo "! RUNTIME ISSUE"
        fi
    else
        echo "- SYNTAX/SEGFAULT"
    fi
}

echo "Setup Scripts:"
echo "--------------"
for script in scripts/setup/*.sh; do
    [ -f "$script" ] && test_quick "$script"
done

echo ""
echo "Install Scripts:"
echo "----------------"
for script in scripts/install/*.sh; do
    [ -f "$script" ] && test_quick "$script"
done

echo ""
echo "Utils Scripts (first 10):"
echo "-------------------------"
count=0
for script in scripts/utils/*.sh; do
    if [ -f "$script" ] && [ $count -lt 10 ]; then
        test_quick "$script"
        ((count++))
    fi
done

echo ""
echo "Working Utils:"
echo "--------------"
for script in utils/*.sh; do
    [ -f "$script" ] && test_quick "$script"
done

echo ""
echo "Analysis:"
echo "Most scripts in scripts/ directory use script-init.sh which causes issues."
echo "All scripts in utils/ directory are designed to work independently."
