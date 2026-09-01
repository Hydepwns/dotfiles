# AGENTS.md

## Repository purpose

This is a chezmoi source repository for cross-platform personal configuration.
The `home/` tree maps to the target home directory; `.tmpl` files use strict Go
templates with `missingkey=error`.

## Required checks

- Run `make lint` after changing shell scripts.
- Run `make codex-check` after changing Codex, MCP, hook, or skill-sync files.
- Run `make test` for broader shell and configuration changes.
- Preview home-directory effects with `chezmoi diff` before applying them.

## Implementation rules

- Shell uses Bash, `set -euo pipefail`, quoted variables, `[[ ]]`, and `printf`.
- Chezmoi templates use `.chezmoi.homeDir` for absolute home paths and trim
  conditional whitespace.
- Add every referenced template flag to both `chezmoi.toml` and
  `.chezmoi.toml.tmpl` before using it.
- Preserve application-owned state. Use merge or idempotent CLI configuration
  instead of overwriting files that Codex, Claude Code, Zed, or gh also edit.
- Do not expose secrets in templates, tests, logs, or generated examples.

## Agent host boundaries

- `~/.agents/skills` is the merged skill view shared by Codex, Claude Code, and Raxol.
- `~/.agents/skills-upstream` and `~/.agents/skills-extra` are source roots, not host-facing inventories.
- Codex configuration belongs under `~/.codex`; Claude Code configuration belongs under `~/.claude`.
- Keep MCP enablement flags aligned between the Claude and Codex renderers.
- Non-managed Codex hooks require explicit user review and trust; never bypass it automatically.
