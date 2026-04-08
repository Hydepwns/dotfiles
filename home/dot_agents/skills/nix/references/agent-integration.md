---
title: Nix-Based Agent Skill Packaging
impact: HIGH
impactDescription: Patterns for packaging and deploying AI agent skills with Nix, Home Manager, and rigup.
tags: nix, agents, skills, packaging, rigup
---

# Nix for Agent Skills

Three projects define the emerging pattern of packaging AI agent skills with Nix.

## agent-skills-nix (Kyure-A)

Declarative management of SKILL.md directories via Home Manager.

### Core concept

Discover skill directories (any dir containing `SKILL.md`), select which to
deploy, bundle into a Nix store derivation, symlink to agent skill paths.

### Usage

```nix
# flake.nix
{
  inputs = {
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    anthropic-skills = { url = "github:anthropics/skills"; flake = false; };
  };

  # home.nix
  programs.agent-skills = {
    sources.anthropic = {
      path = anthropic-skills;
      subdir = "skills";
    };
    skills.enable = [ "frontend-design" "skill-creator" ];
    targets.claude.enable = true;  # -> ~/.claude/skills/
  };
}
```

### Supported targets

`agents`, `claude`, `codex`, `copilot`, `cursor`, `windsurf`, `antigravity`, `gemini`

### Key features

- **Discovery** -- scans source dirs recursively for `SKILL.md`
- **Selection** -- allowlist specific skills, `enableAll`, or explicit with transforms
- **Transforms** -- inject headers, dependency docs, or rewrite skill content at build time
- **Packages** -- symlink Nix package binaries into skill directories
- **DevShell hooks** -- project-local skill installation via `nix develop`

## rigup.nix (YPares)

Composable agent environments as Nix modules ("riglets").

### Core concept

A **riglet** bundles: documentation (SKILL.md + references), tools (Nix packages),
config files (isolated XDG_CONFIG_HOME), deny rules, and MCP servers. A **rig**
composes riglets for a project. Building a rig produces a manifest (RIG.md),
tools on PATH, and merged config.

### Usage modes

```bash
# Shell mode -- enter environment with agent tools
rigup shell

# Build mode -- materialize .rigup/ directory for IDE agents
rigup build

# Run mode -- launch agent harness with full rig
rigup run
```

### rigup.toml

```toml
[rigs.default.riglets]
rigup = ["git-setup", "code-search", "nix-module-system"]
self = ["my-project-skill"]

[rigs.default.config.agent.identity]
name = "Alice"
```

### Key patterns

- **Progressive disclosure** -- riglets declare `disclosure` level (eager, shallow-toc, lazy, none) to control context budget
- **Deny rules** -- restrict dangerous commands (git push, rm -rf) per-riglet
- **MCP integration** -- riglets can declare stdio or HTTP MCP servers
- **Multi-harness** -- same riglets work across Claude Code, Cursor, OpenCode, Copilot

### Built-in riglets

`git-setup`, `code-search`, `coreutils`, `lsp-servers`, `models`,
`nix-module-system`, `riglet-creator`, `typst-reporter`, and harness-specific
entrypoints (`claude-code`, `cursor`, `opencode`, `vscode-copilot`).

## nix-agent (JEFF7712)

MCP server for trusted NixOS automation.

### Core concept

A FastMCP server exposing 8 tools for local NixOS mutation. Designed as a
complement to `mcp-nixos` (read-only discovery).

### MCP tools

| Tool | Purpose |
|------|---------|
| `inspect_state` | Read config file contents |
| `plan_change` | Plan a change, detect scope (home-manager vs system) |
| `apply_patch_set` | Apply file replacements with SHA256 verification |
| `run_formatters` | Run nixpkgs-fmt on changed files |
| `classify_change` | Policy check (high-risk: SSH, networking, hardware) |
| `dry_activate_system` | nixos-rebuild dry-activate |
| `apply_change` | Full workflow: classify -> dry-activate -> switch |

### Policy rules

- **auth-ssh** -- SSH changes require approval
- **network-core** -- networking changes require approval
- **hardware-configuration** -- hardware changes require approval
- All delete operations blocked by default

### Integration as NixOS module

```nix
# In flake.nix inputs
nix-agent.url = "github:JEFF7712/nix-agent";

# In NixOS config
programs.nix-agent.enable = true;
```

## Patterns for your dotfiles

Your chezmoi-based skill deployment (`home/dot_agents/skills/` -> symlinked to
`~/.claude/skills/`) is conceptually similar to agent-skills-nix but uses
chezmoi templates instead of Nix derivations. Both approaches:

- Treat `SKILL.md` directories as the deployment unit
- Support multiple agent targets
- Handle symlink management automatically

To bridge the two worlds: your skills can be consumed by agent-skills-nix users
as a non-flake input source, and rigup riglets can coexist alongside
chezmoi-managed skills.
