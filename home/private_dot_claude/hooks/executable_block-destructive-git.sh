#!/usr/bin/env bash
# Block destructive git commands
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')

# Block git reset --hard
if [[ "$command" =~ git[[:space:]]reset[[:space:]]--hard ]]; then
    echo "Blocked: git reset --hard discards uncommitted changes. Stage changes first or use 'git stash'." >&2
    exit 2
fi

# Block git clean -f (force clean untracked files)
if [[ "$command" =~ git[[:space:]]clean[[:space:]].*-f ]] ||
   [[ "$command" =~ git[[:space:]]clean[[:space:]].*--force ]]; then
    echo "Blocked: git clean -f deletes untracked files permanently. Review with 'git clean -n' first." >&2
    exit 2
fi

# Block git checkout . (discard all changes)
if [[ "$command" =~ git[[:space:]]checkout[[:space:]]\. ]]; then
    echo "Blocked: git checkout . discards all unstaged changes. Use 'git stash' to preserve them." >&2
    exit 2
fi

# Block git restore . (discard all changes)
if [[ "$command" =~ git[[:space:]]restore[[:space:]]\. ]]; then
    echo "Blocked: git restore . discards all unstaged changes. Use 'git stash' to preserve them." >&2
    exit 2
fi

# Block force push to main/master
if [[ "$command" =~ git[[:space:]]push[[:space:]].*--force ]] ||
   [[ "$command" =~ git[[:space:]]push[[:space:]].*-f[[:space:]] ]]; then
    if [[ "$command" =~ (main|master) ]]; then
        echo "Blocked: force push to main/master can destroy shared history. Use a feature branch." >&2
        exit 2
    fi
fi

# Block git branch -D (force delete)
if [[ "$command" =~ git[[:space:]]branch[[:space:]]+-D ]]; then
    echo "Blocked: git branch -D force-deletes without checking merge status. Use 'git branch -d' instead." >&2
    exit 2
fi

exit 0
