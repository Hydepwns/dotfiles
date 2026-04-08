# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chezmoi-based cross-platform dotfiles. Primary platform: macOS (Apple Silicon), with Linux/NixOS support. Template-driven configuration with 30+ conditional features. Shell startup ~386ms via caching and lazy-loading.

## Key Commands

```bash
make install              # chezmoi init --apply (fresh machine)
make update               # Pull remote + chezmoi apply
make diff                 # Preview pending chezmoi changes
chezmoi apply             # Apply local source changes to home directory
chezmoi apply --force     # Skip prompts for modified target files

make lint                 # shellcheck on scripts/ and utils/
make doctor               # Health check (32 checks across tools, config, security)
make perf                 # 5-run shell startup benchmark
make perf-report          # Bare vs configured startup breakdown
make test                 # Test suite (zsh syntax, module loading)

make brew-install         # Install Brewfile packages
make brew-dump            # Update Brewfile from current system
make brew-check           # Check for packages not in Brewfile
make brew-cleanup         # Remove packages not in Brewfile
make dashboard            # Service status dashboard (CLI)
make dashboard-watch      # Dashboard with auto-refresh
make setup-secrets        # Install 1Password, AWS CLI, Infisical, Tailscale
make rotate-keys          # SSH key rotation via 1Password + Tailscale sync
make theme-generate       # Generate all tool configs from unified theme
make lazy-load-stats      # Show lazy loading stats
```

## Chezmoi Architecture

**Source directory**: `home/` (set in `chezmoi.toml` as `sourceDir`). Chezmoi maps `home/dot_foo` -> `~/.foo`, `home/private_dot_config/` -> `~/.config/`.

**Template system**: Files ending in `.tmpl` use Go template syntax. All boolean flags live in `chezmoi.toml` under `[data]`:

```
# Identity: name, email, github, gpg_signing_key, age_recipient, brewPrefix
# Shell:    starship, ohmyzsh, oh_my_zsh_theme, oh_my_zsh_plugins
# Tools:    mise, rust, elixir, erlang, lua, direnv, devenv, nix
# Services: tailscale, onepassword, aws, infisical, orbstack
# macOS:    paperwm, raycast, llvm, postgres, psql
# Web3:     foundry, huff, solana
# Apps:     takopi, work, personal
# Theme:    [data.theme] -- full Synthwave84 palette (bg, fg, accent, ANSI colors)
```

Use in templates: `{{- if .rust -}}...{{- end -}}`. Use `{{- -}}` to trim whitespace.

**Template strictness**: `[template] options = ["missingkey=error"]` -- referencing an undefined key is a hard error. Always check that a flag exists in `chezmoi.toml` before using it in a template.

**Run-onchange scripts** (auto-execute on `chezmoi apply`):

- `run_onchange_after_brew-bundle.sh.tmpl` -- runs `brew bundle install` when Brewfile hash changes
- `run_onchange_after_mise-install.sh.tmpl` -- runs `mise install` when mise config changes
- `run_onchange_after_reload-hammerspoon.sh.tmpl` -- reloads Hammerspoon on config change (macOS)
- `run_onchange_after_sync-skills.sh.tmpl` -- symlinks skills from `~/.agents/skills/` to `~/.claude/skills/`

**Age encryption**: Sensitive files use `encrypted_` prefix. Decryption key is stored in 1Password (secure note "AGE-SECRET-KEY" in Employee vault) and accessed via `~/.config/chezmoi/age-op-decrypt.sh` wrapper -- no plaintext key on disk. To edit encrypted templates, decrypt with `age -d -i <(op read "op://Employee/AGE-SECRET-KEY/notesPlain" | grep "^AGE-SECRET-KEY-")`, edit, re-encrypt with `age -r "<recipient>"`, verify with `chezmoi diff`. `chezmoi re-add` does NOT work for encrypted files.

Encrypted files:

- `home/dot_ssh/encrypted_config.tmpl` -- SSH config with Tailscale hosts, 1Password SSH agent on macOS
- `home/dot_zsh/core/encrypted_secrets.zsh` -- 1Password/AWS/Infisical integration
- `home/dot_takopi/encrypted_takopi.toml` -- takopi bot config

## Modular Zsh Architecture

Entry: `dot_zshrc.tmpl` -> sources `~/.zsh/modules.zsh`

`modules.zsh` auto-sources in order:

1. `core/*.zsh` (alphabetically: config, lazy-loading, package-managers, paths, prompt, secrets, ssh, tools, xdg)
2. `core/platforms/*.zsh` (macos.zsh or linux.zsh)
3. `aliases/*.zsh`
4. `functions/*.zsh`
5. `env.zsh` (explicit, not wildcard)

**Performance-critical patterns** (don't break these):

- `compinit -C` when `.zcompdump` is fresh (<24h), full `compinit` only when stale
- Starship init cached to `$XDG_CACHE_HOME/zsh-completions/starship-init.zsh` (24h TTL)
- Tool completions (mise, chezmoi) cached via `_cache_completion()` helper (24h TTL)
- Oh My Zsh conditionally skipped when `starship = true` (saves ~1000ms)
- Fastfetch deferred to one-shot `precmd` hook (runs after first prompt, not before)
- `modules.zsh` sources `env.zsh` explicitly -- do NOT use root-level wildcards (stale files caused 1357ms regression)

**PATH management**: `core/paths.zsh.tmpl` defines a `PATH_REGISTRY` associative array and `build_path()` function. All PATH additions go through `add_to_path()` which checks directory existence. Registry keys: `base`, `macos_brew`, `linux_local`, `mise`, `rust`, `pnpm_macos`, `pnpm_linux`, `pipx`, `npm_global`, `foundry`, `huff`, `solana`, `llvm`, `postgres_homebrew`, `postgres_app`, `erlang`, `elixir_mix`, `lua_luarocks`, `nix_profile`.

## Writing Scripts

Scripts source `scripts/utils/simple-init.sh` for: `set -euo pipefail`, color vars, `log_info`/`log_success`/`log_error`/`log_warning`/`log_debug`, auto-detected `$DOTFILES_ROOT`. Logging is centralized in `scripts/utils/logging.sh` (sourced by simple-init.sh). Supports `QUIET=true` to suppress info/success and `DEBUG=true` for debug output. Also provides short aliases: `info`, `success`, `warn`, `error`.

Shared constants from `scripts/utils/constants.sh`: exit codes (`EXIT_SUCCESS` through `EXIT_TIMEOUT`), identity vars from chezmoi data (`GITHUB_USER`, `USER_NAME`, `USER_EMAIL`, `AGE_RECIPIENT`), infrastructure (`OP_VAULT`, `TAILSCALE_USER`), platform detection (`PLATFORM`, `ARCH`).

Setup scripts follow the pattern: `scripts/setup/setup-<tool>.sh` with subcommands (`install`, `status`, `config`). Add a Makefile target with `## comment` for `make help` discoverability.

## Pre-commit Hooks

Commits run: trailing-whitespace, end-of-file-fixer, check-yaml, check-added-large-files (500KB), check-merge-conflict, shellcheck (error level, `-x` to follow sources, excludes `home/dot_zsh/*.zsh`), black (Python), prettier (JSON/YAML/Markdown). Encrypted files (`encrypted_*`) are excluded from whitespace hooks.

## Theming

Single source of truth: `[data.theme]` in `chezmoi.toml` (Synthwave84 palette). Templates reference colors as `{{ .theme.bg }}`, `{{ .theme.accent }}`, etc. Applied to: fzf (`tools.zsh.tmpl`), Starship (`starship.toml.tmpl`), Hammerspoon alerts. Static theme files in `config/theme/synthwave84.toml` for tools that can't use chezmoi templates.

## Adding Features

**New alias**: Add to `home/dot_zsh/aliases/dev.zsh`

**New conditional tool**:

1. Add flag to `chezmoi.toml`: `mytool = true`
2. Gate in templates: `{{- if .mytool -}}...{{- end -}}`

**New setup script**:

1. Create `scripts/setup/setup-mytool.sh` (source `simple-init.sh`, add subcommands)
2. Add Makefile target with `## comment`
3. Add to `.PHONY` line

**New PATH entry**: Add key to `PATH_REGISTRY` in `paths.zsh.tmpl`, add conditional `add_to_path` call in `build_path()`

## ETHSkills & Web3 Context

Local skills (`ethskills/`, `solidity-audit/`, `noir/`) provide offline Ethereum, Solidity, and ZK knowledge. For supplemental or latest info, fetch from [ETHSkills](https://ethskills.com/) live sources (URLs listed in `solidity-audit/live-sources.md`).

| Live Skill | URL                                | Use Case                                    |
| ---------- | ---------------------------------- | ------------------------------------------- |
| Security   | `ethskills.com/security/SKILL.md`  | Reentrancy, oracles, vault inflation, MEV   |
| Tools      | `ethskills.com/tools/SKILL.md`     | Blockscout MCP, Foundry, abi.ninja          |
| L2s        | `ethskills.com/l2s/SKILL.md`       | Cross-chain, bridging, L2 economics         |
| Standards  | `ethskills.com/standards/SKILL.md` | ERC-8004, EIP-7702, token standards         |
| Gas        | `ethskills.com/gas/SKILL.md`       | Current costs (mainnet ~$0.002, L2 ~$0.002) |

**Blockscout MCP**: Configured in `~/.mcp.json`. Provides type-safe blockchain data queries (balances, tokens, NFTs, contracts) across multiple chains via Model Context Protocol.

## MCP Servers

Managed via `~/.mcp.json` (chezmoi template: `home/dot_mcp.json.tmpl`). Toggle in `chezmoi.toml`, then `chezmoi apply`.

| Server     | Flag      | Transport | Notes                              |
| ---------- | --------- | --------- | ---------------------------------- |
| context7   | always on | stdio     | Library docs via npx               |
| blockscout | always on | http      | Blockchain data queries            |
| datadog    | `datadog` | http/OAuth| us5.datadoghq.com, no secrets      |
| sentry     | `sentry`  | http/OAuth| mcp.sentry.dev, no secrets         |
| signoz     | `signoz`  | stdio     | API key from 1Password at runtime  |

**Datadog:** Enable `datadog = true` in chezmoi.toml, `chezmoi apply`. OAuth via browser.

**Sentry:** Enable `sentry = true` in chezmoi.toml, `chezmoi apply`. OAuth via browser.

**SigNoz setup:**
1. `make setup-signoz-mcp` (builds from source, requires Go)
2. Store API key: `op item create --vault Employee --category login --title "SigNoz API Key" credential=<key>`
3. Set `signoz = true` in chezmoi.toml, `chezmoi apply`

## Claude Code Skills

Skills in `home/dot_agents/skills/` are deployed to `~/.agents/skills/` via chezmoi and symlinked to `~/.claude/skills/` by `run_onchange_after_sync-skills.sh.tmpl`.

| Skill | Source | Triggers on |
|-------|--------|-------------|
| claude-api | Vendored (Anthropic) | `anthropic` imports, SDK usage |
| droo-stack | Custom | Elixir, TS, Go, Rust, C, Zig, Python, Lua, Shell, Noir, Chezmoi |
| raxol | Custom | Raxol TUI/agent imports, headless/MCP tools |
| noir | Custom | `.nr` files, Nargo.toml, ZK circuits, Aztec contracts/security/e2e testing |
| solidity-audit | Custom | `.sol` files, foundry.toml, auditing, security review |
| ethskills | Custom | Ethereum tooling, EIP/ERC standards, framework selection |
| design-ux | Custom | Component design, layout, tokens, accessibility, TUI aesthetics, DESIGN.md |
| nix | Custom | `.nix` files, flakes, NixOS, Home Manager, agent-skills packaging, rigup |
| native-code | Custom | NIFs (C/Rust), SIMD (Zig), erl_nif.h, Rustler, BEAM native boundary |

Skills provide detailed incorrect/correct code examples. CLAUDE.md provides preferences and philosophy. To add a new skill: create `home/dot_agents/skills/<name>/SKILL.md`, run `chezmoi apply`.

**Skills map** -- how skills relate:

```
                    droo-stack (code patterns)
                   /    |    \        \        \
             Elixir   TS/JS   Go/Rust   C/Zig  Py/Lua/Shell
               |       |                 |
            raxol    design-ux     native-code
          (TUI)    (UI/UX)      (NIFs + SIMD)
               \       /
            terminal aesthetics

              ethskills (ecosystem)
             /         \
    solidity-audit    noir (ZK)
    (contracts)     (circuits)

         nix (Nix ecosystem)
        / |  \
  flakes NixOS Home Manager
              \
        agent-skills packaging
```

Each skill has "See also" cross-references in its SKILL.md.

## Code Style

- Shell: bash with `set -euo pipefail`, shellcheck compliant, quote all variables
- Use `[[ ]]` over `[ ]`, `$((expr))` over `((expr))` (the latter fails under `set -e` when result is 0)
- Guard external commands that may return non-zero: `grep ... || true`, `command -v ... &>/dev/null`
- Chezmoi templates: `{{- -}}` to trim whitespace, use `.chezmoi.homeDir` not `~`
