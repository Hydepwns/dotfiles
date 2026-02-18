#!/usr/bin/env bash
# Claude Code statusline - shows model, context, cost, time
set -euo pipefail

# Read JSON from stdin
input=$(cat)

# Extract values with jq
model=$(echo "$input" | jq -r '.model // "unknown"')
cwd=$(echo "$input" | jq -r '.cwd // ""')
session_cost=$(echo "$input" | jq -r '.session.cost_usd // 0')
context_used=$(echo "$input" | jq -r '.session.context_used_percent // 0')
elapsed_seconds=$(echo "$input" | jq -r '.session.elapsed_seconds // 0')

# Get git branch if in a repo
branch=""
if [[ -n "$cwd" ]] && [[ -d "$cwd/.git" || -f "$cwd/.git" ]]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "")
fi

# Format model name (strip provider prefix)
model_short="${model##*/}"
model_short="${model_short%-*}"

# Format folder name (just basename)
folder="${cwd##*/}"

# Format elapsed time
hours=$((elapsed_seconds / 3600))
minutes=$(((elapsed_seconds % 3600) / 60))
seconds=$((elapsed_seconds % 60))
if [[ $hours -gt 0 ]]; then
    time_str="${hours}h ${minutes}m"
elif [[ $minutes -gt 0 ]]; then
    time_str="${minutes}m ${seconds}s"
else
    time_str="${seconds}s"
fi

# Build context bar (10 chars wide)
bar_width=10
filled=$((context_used * bar_width / 100))
empty=$((bar_width - filled))
bar=$(printf '%*s' "$filled" '' | tr ' ' '#')
bar+=$(printf '%*s' "$empty" '' | tr ' ' '-')

# Color code context (ANSI: green <50%, yellow 50-79%, red 80%+)
if [[ $context_used -lt 50 ]]; then
    color="\033[32m"  # green
elif [[ $context_used -lt 80 ]]; then
    color="\033[33m"  # yellow
else
    color="\033[31m"  # red
fi
reset="\033[0m"

# Line 1: model, folder, branch
line1="[${model_short}] ${folder}"
[[ -n "$branch" ]] && line1+=" | ${branch}"

# Line 2: context bar, cost, time
line2="${color}[${bar}]${reset} ${context_used}% | \$${session_cost} | ${time_str}"

printf '%s\n%b\n' "$line1" "$line2"
