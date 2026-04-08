---
name: nix
description: >
  Nix language, flakes, NixOS, Home Manager, and agent-skills packaging.
  TRIGGER when: working with .nix files, flake.nix, flake.lock, Nargo.toml
  (Nix packaging context), NixOS configuration, Home Manager modules,
  nix-agent MCP tools, agent-skills-nix deployment, or rigup.nix riglets.
  DO NOT TRIGGER when: only using nix PATH (chezmoi handles that), or
  working on ZK circuits (use noir skill), or Nix language is incidental
  to another domain.
metadata:
  author: hydepwns
  version: "1.0.0"
  tags: nix, nixos, flakes, home-manager, devshell, agent-skills, rigup
---

# nix

Practical patterns for the Nix ecosystem: the language itself, flake
architecture, NixOS/Home Manager configuration, package building, and the
emerging pattern of packaging AI agent skills as Nix derivations.

## When to use

- Writing or reviewing `.nix` files (flakes, modules, overlays, packages)
- Configuring NixOS or Home Manager
- Building Nix packages (mkDerivation, buildGoModule, buildNpmPackage, etc.)
- Managing Nix profiles and registries
- Packaging agent skills for Nix-based deployment (agent-skills-nix, rigup)
- Using nix-agent MCP tools for NixOS automation

## When NOT to use

- Nix PATH setup in chezmoi -- handled by `paths.zsh.tmpl` and `chezmoi.toml`
- ZK circuit design -- use noir skill
- Solidity or Ethereum -- use solidity-audit or ethskills

## Reading guide

| Working on | Read |
|-----------|------|
| Nix language idioms, builtins, let/with/inherit | [references/language](references/language.md) |
| Flake structure, inputs, outputs, lockfiles | [references/flakes](references/flakes.md) |
| NixOS modules, options, services | [references/nixos](references/nixos.md) |
| Home Manager config, programs, activation | [references/home-manager](references/home-manager.md) |
| Building packages (mkDerivation, language builders) | [references/packaging](references/packaging.md) |
| Nix profiles, registries, nix-env alternatives | [references/profiles](references/profiles.md) |
| Agent skills as Nix packages (agent-skills-nix, rigup, nix-agent MCP) | [references/agent-integration](references/agent-integration.md) |

## Key principles

1. **Reproducibility first** -- pin inputs, use flake.lock, avoid impure operations
2. **Composition over mutation** -- overlay and override, never patch in place
3. **Lazy evaluation** -- Nix is lazy; structure code to exploit this
4. **Declarative over imperative** -- describe the target state, not the steps
5. **Module system is the API** -- options with types, defaults, and docs

## Common pitfalls

| Mistake | Fix |
|---------|-----|
| Using `rec { }` when `let ... in` works | `rec` pollutes scope and causes infinite recursion -- prefer `let` |
| `with pkgs;` at module level | Shadows names silently -- use `pkgs.foo` or selective `inherit` |
| Forgetting `meta.mainProgram` | Breaks `nix run` -- always set it for packages with binaries |
| `builtins.fetchurl` in flakes | Impure -- use flake inputs or `fetchurl` from nixpkgs |
| Mutable channel references | Pin nixpkgs as a flake input, not `<nixpkgs>` |
| `nix-env -i` for system packages | Use `environment.systemPackages` or `home.packages` |
| Testing with `nix-build` when flake | Use `nix build .#package` -- `nix-build` ignores flake.nix |

## See also

- droo-stack -- shell patterns for nix-related scripts
- chezmoi templates in droo-stack -- `paths.zsh.tmpl` nix conditionals
