#!/usr/bin/env bash
# Block direct push to main/master - require feature branches
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')

if [[ "$command" =~ git[[:space:]]+push[[:space:]]+(origin[[:space:]]+)?(main|master)([[:space:]]|$) ]]; then
    echo "Blocked: Direct push to main/master. Use a feature branch and PR instead." >&2
    exit 2
fi

if [[ "$command" =~ git[[:space:]]+push[[:space:]]+-f|git[[:space:]]+push[[:space:]]+--force ]]; then
    echo "Blocked: Force push is destructive. If you really need this, ask the user to run it manually." >&2
    exit 2
fi

exit 0
