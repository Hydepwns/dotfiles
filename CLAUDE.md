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
# Tools:    mise, rust, elixir, erlang, lua, direnv, devenv, nix, emacs
# Services: tailscale, onepassword, aws, infisical, orbstack
# macOS:    paperwm, raycast, llvm, postgres, psql
# Web3:     foundry, huff, solana
# Apps:     work, personal
# MCP:      datadog, sentry, signoz, regen, coingecko, digest, recall, autoresearch, watchdog, prepper, sentinel, patchbot
# Theme:    [data.theme] -- full Synthwave84 palette (bg, fg, accent, ANSI colors)
#           [data.theme.soft] -- Synthwave84 Soft variant + syntax roles (Zed/Emacs)
```

Use in templates: `{{- if .rust -}}...{{- end -}}`. Use `{{- -}}` to trim whitespace.

**Template strictness**: `[template] options = ["missingkey=error"]` -- referencing an undefined key is a hard error. Always check that a flag exists in `chezmoi.toml` before using it in a template.

**Run-onchange scripts** (auto-execute on `chezmoi apply`):

- `run_onchange_after_brew-bundle.sh.tmpl` -- runs `brew bundle install` when Brewfile hash changes
- `run_onchange_after_mise-install.sh.tmpl` -- runs `mise install` when mise config changes
- `run_onchange_after_reload-hammerspoon.sh.tmpl` -- reloads Hammerspoon on config change (macOS)
- `run_after_sync-skills.sh.tmpl` -- symlinks skills from `~/.agents/skills/` to `~/.claude/skills/` (always runs; script is idempotent)

**Age encryption**: Sensitive files use `encrypted_` prefix. Decryption key is stored in 1Password (secure note "AGE-SECRET-KEY" in Employee vault) and accessed via `~/.config/chezmoi/age-op-decrypt.sh` wrapper -- no plaintext key on disk. To edit encrypted templates, decrypt with `age -d -i <(op read "op://Employee/AGE-SECRET-KEY/notesPlain" | grep "^AGE-SECRET-KEY-")`, edit, re-encrypt with `age -r "<recipient>"`, verify with `chezmoi diff`. `chezmoi re-add` does NOT work for encrypted files.

Encrypted files:

- `home/dot_ssh/encrypted_config.tmpl` -- SSH config with Tailscale hosts, 1Password SSH agent on macOS
- `home/dot_zsh/core/encrypted_secrets.zsh` -- 1Password/AWS/Infisical integration

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

**Two variants.** `[data.theme]` is the base palette (Ghostty, tmux, fzf, Starship, btop, yazi). `[data.theme.soft]` is the lower-contrast **Synthwave84 Soft** variant that Zed uses, and it is the only block carrying syntax roles (`keyword`, `string`, `function`, `type`, ...) plus diagnostic and git colors. Emacs consumes `{{ .theme.soft.* }}` for UI and syntax, but reuses the base `{{ .theme.* }}` ANSI keys for terminal faces -- Zed's Soft variant leaves `terminal.ansi.*` at base values, so shell buffers match Ghostty exactly.

Authoritative source for both is the shipped Zed theme JSON (`~/Library/Application Support/Zed/extensions/installed/synthwave84/themes/synthwave84.json`), not `config/theme/synthwave84.toml`, which had drifted on `keyword` and `type`.

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

Local skills (`ethskills/`, `solidity-auditor/`, `noir/`) provide offline Ethereum, Solidity, and ZK knowledge. For supplemental or latest info, fetch from [ETHSkills](https://ethskills.com/) live sources (URLs listed in `solidity-auditor/live-sources.md`).

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

| Server       | Flag             | Transport  | Notes                             |
| ------------ | ---------------- | ---------- | --------------------------------- |
| context7     | always on        | stdio      | Library docs via npx              |
| blockscout   | always on        | http       | Blockchain data queries           |
| coingecko    | `coingecko`      | http       | Crypto market data                |
| digest       | `digest`         | stdio      | Multi-platform activity digest    |
| recall       | `recall`         | stdio      | Knowledge capture/retrieval (FTS5) |
| autoresearch | `autoresearch`   | stdio      | Autonomous experiment runner      |
| watchdog     | `watchdog`       | stdio      | Repo health monitor               |
| prepper      | `prepper`        | stdio      | Pre-session context builder       |
| sentinel     | `sentinel`       | stdio      | On-chain contract monitor         |
| patchbot     | `patchbot`       | stdio      | Polyglot dependency updater       |
| signoz       | `signoz`         | stdio      | Primary observability. API key from 1Password at runtime |
| regen        | `regen`          | stdio      | Fluidify Regen incidents; wrapper injects `regen_url` (+ optional cookie). Correlates with signoz |
| datadog      | `datadog`        | http/OAuth | Disabled fallback (`datadog = false`). us5.datadoghq.com, no secrets |
| sentry       | `sentry`         | http/OAuth | mcp.sentry.dev, no secrets        |

Agent MCP servers (coingecko through patchbot) all share the same `<binary> serve` invocation pattern — they're CLIs from [agent-skills](https://github.com/DROOdotFOO/agent-skills) that double as MCP stdio servers.

**SigNoz (primary):** Observability backend for Riddler (OTel -> SigNoz on mini-axol). Setup:

1. `make setup-signoz-mcp` (builds from source, requires Go)
2. Token: read at runtime from `op://Employee/SigNoz mini-axol/service_account_token` (the wrapper resolves it; no separate item to create)
3. Set `signoz = true` in chezmoi.toml, `chezmoi apply`. Requires Tailscale up (`signoz_url` is a tailnet host).

**Regen:** Fluidify Regen incident reader (`regen serve` from agent-skills `agents/regen/`), symmetric with signoz. Live at `regen_url` = `http://mini-axol.tail9b2ce8.ts.net:3302` (origin only; the client appends `/api/v1`). Wrapper `executable_regen-mcp-wrapper.sh.tmpl` exports `REGEN_BASE_URL` (`regen_url`) and `REGEN_ENABLE_WRITE=1` (drop for read-only). Regen OSS has no API-token auth and runs in **open mode** behind the Tailscale ACL -- no secret needed; the commented `REGEN_SESSION_COOKIE` `op read` line is only for a future local-auth/SAML instance. Guardrail: do not create a Regen user or enable SAML, or open mode closes and the wrapper breaks.

**Datadog (disabled fallback):** Kept for one-flag rollback. Enable `datadog = true` in chezmoi.toml, `chezmoi apply`. OAuth via browser.

**Sentry:** Enable `sentry = true` in chezmoi.toml, `chezmoi apply`. OAuth via browser.

## Agent Skills

Skills are portable `SKILL.md` files sourced from [DROOdotFOO/agent-skills](https://github.com/DROOdotFOO/agent-skills), pulled via `home/.chezmoiexternal.toml` on `chezmoi apply` (refresh window 168h; force with `--refresh-externals`) to `~/.agents/skills/`. Two hosts load the same files:

- **Raxol agent (primary host).** `Raxol.Agent.Skills.Store` scans `~/.agents/skills/` and `~/.agents/skills-extra/` for `**/SKILL.md` and holds them as read-only procedural memory, reached by the agent via the `skills_list` / `skill_view` / `skill_manage` tools. Enabled by `config :raxol_agent, skills_provider: Raxol.Agent.Skills.Store` in the raxol repo (`packages/raxol_agent/config/config.exs`); external dirs are set alongside it.
- **Claude Code (secondary host).** `run_after_sync-skills.sh.tmpl` symlinks `~/.agents/skills/*` and `~/.agents/skills-extra/*` into `~/.claude/skills/*`, where Claude Code auto-injects a skill when its trigger clause matches the conversation.

**Skills roots:**

- `~/.agents/skills/` -- the agent-skills collection (chezmoi external, read-only). To add/port a skill, add it under `skills/` in the [agent-skills](https://github.com/DROOdotFOO/agent-skills) repo, push to `main`, then `chezmoi apply --refresh-externals`.
- `~/.agents/skills-extra/` -- chezmoi-vendored third-party skills the external does not manage (source: `home/dot_agents/skills-extra/`).
- `~/.raxol/skills/` -- writable managed root for **agent-authored** skills only (the raxol curation loop writes here). Runtime state, left unmanaged by chezmoi. Human and vendored skills come from the chezmoi-managed externals above, never here.

**Code pattern skills** -- language-specific examples and idioms:

| Skill       | Triggers on                                                                |
| ----------- | -------------------------------------------------------------------------- |
| claude-api  | `anthropic` imports, SDK usage                                             |
| droo-stack  | Elixir, TS, Go, Rust, C, Zig, Python, Lua, Shell, Noir, Chezmoi            |
| raxol       | Raxol TUI/agent imports, headless/MCP tools                                |
| raxol-payments | :raxol_payments/:raxol_earn, Xochi/Riddler, agent wallets, ACP jobs      |
| raxol-symphony | :raxol_symphony, tracker-driven coding-agent orchestration             |
| design-ux   | Component design, layout, tokens, accessibility, TUI aesthetics, DESIGN.md |
| nix         | `.nix` files, flakes, NixOS, Home Manager, agent-skills packaging, rigup   |
| native-code | NIFs (C/Rust), SIMD (Zig), erl_nif.h, Rustler, BEAM native boundary        |

**Web3 skills** -- blockchain development, auditing, and data:

| Skill          | Triggers on                                                                |
| -------------- | -------------------------------------------------------------------------- |
| ethskills      | Ethereum tooling, EIP/ERC standards, framework selection                   |
| solidity-auditor | `.sol` files, foundry.toml, auditing, security review                      |
| noir           | `.nr` files, Nargo.toml, ZK circuits, Aztec contracts/security/e2e testing |
| blockscout     | On-chain data queries, contract state, token balances, ENS, NFT holdings   |
| coingecko      | Token prices, market caps, DEX pools, trending tokens, price history       |

**MCP-companion skills** -- reference docs for MCP agent tools:

| Skill        | Triggers on                                                   |
| ------------ | ------------------------------------------------------------- |
| autoresearch | Experiment status, "run another iteration", `/autoresearch`   |
| patchbot     | Outdated dependencies, "update deps", `/patchbot`             |
| prepper      | Project briefings, "catch me up", "prep me", `/prepper`       |
| sentinel     | Contract monitoring, on-chain alerts, suspicious transactions |
| watchdog     | Repo health, stale PRs, CI status, security advisories        |

**Workflow skills** (40 total) -- architect, code-review, tdd, focused-fix, adversarial-reviewer, prd-to-plan, prd-to-issues, release, and more. Each has a SKILL.md with trigger conditions.

Skills provide detailed incorrect/correct code examples. CLAUDE.md provides preferences and philosophy. To add a new skill: add to the [agent-skills](https://github.com/DROOdotFOO/agent-skills) repo, push to `main`, then `chezmoi apply --refresh-externals`.

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
             /    |    \
    solidity    noir    blockscout -- coingecko
    -audit     (ZK)    (on-chain)    (markets)
  (contracts)           |
                     sentinel (monitor)

         nix (Nix ecosystem)
        / |  \
  flakes NixOS Home Manager
              \
        agent-skills packaging

    MCP companions (agent tools)
    /    |    \       \        \
 auto  patch  prepper sentinel watchdog
 research bot (brief) (chain)  (repo)
```

Each skill has "See also" cross-references in its SKILL.md.

## Code Style

- Shell: bash with `set -euo pipefail`, shellcheck compliant, quote all variables
- Use `[[ ]]` over `[ ]`, `$((expr))` over `((expr))` (the latter fails under `set -e` when result is 0)
- Guard external commands that may return non-zero: `grep ... || true`, `command -v ... &>/dev/null`
- Chezmoi templates: `{{- -}}` to trim whitespace, use `.chezmoi.homeDir` not `~`
