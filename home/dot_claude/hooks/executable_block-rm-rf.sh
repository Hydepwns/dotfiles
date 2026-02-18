#!/usr/bin/env bash
# Block rm -rf commands and suggest trash instead
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')

if [[ "$command" =~ rm[[:space:]]+-[^[:space:]]*r[^[:space:]]*f|rm[[:space:]]+-[^[:space:]]*f[^[:space:]]*r ]]; then
    echo "Blocked: rm -rf is destructive. Use 'trash' instead (brew install macos-trash)." >&2
    exit 2
fi

exit 0
