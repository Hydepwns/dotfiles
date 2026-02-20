#!/usr/bin/env bash
# Claude Code statusline - shows model, context, cost, time
set -euo pipefail

# Read JSON from stdin
input=$(cat)

# Extract values with jq (handles new nested format)
model=$(echo "$input" | jq -r 'if .model | type == "object" then (.model.display_name // .model.id) else .model end // "unknown"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
context_used=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
elapsed_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
elapsed_seconds=$((elapsed_ms / 1000))

# Token counts
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')

# Lines changed
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Get git branch if in a repo
branch=""
if [[ -n "$cwd" ]] && [[ -d "$cwd/.git" || -f "$cwd/.git" ]]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "")
fi

# Format model name (use display_name directly or strip provider prefix from id)
if [[ "$model" == *"/"* ]] || [[ "$model" == *"-"* && ${#model} -gt 10 ]]; then
    model_short="${model##*/}"
    model_short="${model_short%-*}"
else
    model_short="$model"
fi

# Format folder name (just basename)
folder="${cwd##*/}"

# Format elapsed time (fixed-width: mm:ss or hh:mm:ss)
hours=$((elapsed_seconds / 3600))
minutes=$(((elapsed_seconds % 3600) / 60))
seconds=$((elapsed_seconds % 60))
if [[ $hours -gt 0 ]]; then
    time_str=$(printf '%d:%02d:%02d' "$hours" "$minutes" "$seconds")
else
    time_str=$(printf '%02d:%02d' "$minutes" "$seconds")
fi

# Format cost (fixed-width: $X.XXXXX, 8 chars total)
cost_str=$(printf '$%.5f' "$session_cost")

# Format percentage (fixed-width: 3 chars right-aligned)
pct_str=$(printf '%3d%%' "$context_used")

# Format tokens (compact: Xk/Yk)
format_tokens() {
    local n=$1
    if [[ $n -ge 1000 ]]; then
        printf '%dk' $((n / 1000))
    else
        printf '%d' "$n"
    fi
}
tokens_str="$(format_tokens "$input_tokens")/$(format_tokens "$output_tokens")"

# Format lines changed
if [[ $lines_added -gt 0 || $lines_removed -gt 0 ]]; then
    lines_str="+${lines_added}/-${lines_removed}"
else
    lines_str=""
fi

# Build context bar (10 chars wide, thin bars style)
bar_width=10
filled=$((context_used * bar_width / 100))
empty=$((bar_width - filled))
bar_fill=$(printf '%*s' "$filled" '' | tr ' ' '━')
bar_empty=$(printf '%*s' "$empty" '' | tr ' ' '─')
bar="│${bar_fill}${bar_empty}│"

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

# Line 2: context bar, percentage, tokens, cost, time, lines
line2="${color}${bar}${reset} ${pct_str} | ${tokens_str} | ${cost_str} | ${time_str}"
[[ -n "$lines_str" ]] && line2+=" | ${lines_str}"

printf '%s\n%b\n' "$line1" "$line2"
