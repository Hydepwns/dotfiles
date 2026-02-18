#!/usr/bin/env bash
# Block direct push to main/master - require feature branches
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')

# Block push to main/master in any position
if [[ "$command" =~ git[[:space:]]+push[[:space:]]+(.*[[:space:]])?(main|master)([[:space:]]|$) ]]; then
    echo "Blocked: Direct push to main/master. Use a feature branch and PR instead." >&2
    exit 2
fi

# Block force push with flag in any position (but allow --force-with-lease)
if [[ "$command" =~ git[[:space:]]+push ]] && [[ "$command" =~ [[:space:]](-f|--force)([[:space:]]|$) ]] && [[ ! "$command" =~ --force-with-lease ]]; then
    echo "Blocked: Force push is destructive. Use --force-with-lease or ask the user to run manually." >&2
    exit 2
fi

exit 0
