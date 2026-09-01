#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE_STATE="$DOTFILES_ROOT/home"
dry_run=0

if [[ "${1:-}" == "--dry-run" ]]; then
    dry_run=1
elif [[ $# -gt 0 ]]; then
    printf 'Usage: %s [--dry-run]\n' "$0" >&2
    exit 2
fi

chezmoi_args=(
    --source "$SOURCE_STATE"
    --working-tree "$DOTFILES_ROOT"
)
targets=(
    "$HOME/.agents/skills-upstream"
    "$HOME/.codex/AGENTS.md"
    "$HOME/.codex/hooks.json"
)

if [[ "$dry_run" -eq 1 ]]; then
    chezmoi "${chezmoi_args[@]}" apply \
        --dry-run \
        --verbose \
        --refresh-externals=never \
        "${targets[@]}"
    exit 0
fi

chezmoi "${chezmoi_args[@]}" apply \
    --refresh-externals=always \
    "${targets[@]}"

bash "$DOTFILES_ROOT/home/run_after_sync-skills.sh.tmpl"
chezmoi "${chezmoi_args[@]}" execute-template \
    <"$DOTFILES_ROOT/home/run_onchange_after_setup-codex.sh.tmpl" |
    bash

printf '[dotfiles] Codex target applied without reconciling unrelated files\n'
