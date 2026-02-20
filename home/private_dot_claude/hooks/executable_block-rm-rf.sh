#!/usr/bin/env bash
# Block rm -rf commands and suggest trash instead
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')

# Match rm with both -r and -f flags in any form:
# - rm -rf, rm -fr (combined)
# - rm -r -f, rm -f -r (separate)
# - rm --recursive --force, rm --force --recursive (long form)
# - xargs rm -rf (piped)
if [[ "$command" =~ rm[[:space:]]+-[^[:space:]]*r[^[:space:]]*f ]] ||
   [[ "$command" =~ rm[[:space:]]+-[^[:space:]]*f[^[:space:]]*r ]] ||
   [[ "$command" =~ rm[[:space:]].*-r.*-f ]] ||
   [[ "$command" =~ rm[[:space:]].*-f.*-r ]] ||
   [[ "$command" =~ rm[[:space:]].*--recursive.*--force ]] ||
   [[ "$command" =~ rm[[:space:]].*--force.*--recursive ]] ||
   [[ "$command" =~ xargs[[:space:]].*rm ]]; then
    echo "Blocked: rm -rf is destructive. Use 'trash' instead (brew install macos-trash)." >&2
    exit 2
fi

exit 0
