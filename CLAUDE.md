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
make doctor               # Health check across tools, config, security
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

make setup-emacs          # Emacs config, packages, grammars, daemon restart
make emacs-status         # Emacs version, daemon, packages, grammars
make emacs-grammars       # Compile missing tree-sitter grammars
make emacs-restart        # Restart the Emacs daemon
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

**Files the app also writes (`modify_` scripts)**: a plain managed file is authoritative, so `chezmoi apply` deletes any key the app added at runtime. That is the recurring `MM` in `chezmoi status`. When both chezmoi and an application own parts of a file, use a `modify_` source instead: chezmoi pipes the **current target** to the script on stdin and takes its stdout as the new target, so it can merge rather than overwrite.

`home/private_dot_claude/modify_settings.json.tmpl` is the worked example. It embeds the managed JSON in a quoted heredoc and merges it over the existing file with `jq '. * $managed'` -- managed keys win, unmanaged keys (`model`, `effortLevel`, anything `/config` adds later) survive. It falls back to emitting the managed block when stdin is empty, invalid JSON, or `jq` is missing, so a fresh machine still gets a correct file.

Two constraints when writing one:

- **It must be idempotent.** chezmoi runs the script for `status` and `diff` too, so if `f(current) != current` once converged, the file reports drift forever. Verify with `chezmoi status <target>` after applying.
- **Deletion stops propagating.** A merge only adds, so removing a key from the source no longer removes it from the target; delete it by hand.

`home/private_dot_config/zed/modify_private_settings.json.tmpl` is the same recipe for Zed, which rewrites `settings.json` on every UI setting change. Note the attribute order in that filename: `modify_` precedes `private_`, and the target still lands at `0600`.

`~/.gitconfig` needed a different answer. It is INI, so `jq` does not apply, and only two blocks ever drift -- `gh auth setup-git` rewrites the credential helpers through `git config`, which emits tab indentation and a trailing space after the empty `helper =`. Rather than add a `modify_` script, those blocks in `dot_gitconfig.tmpl` now match `git config` byte-for-byte, so gh's rewrite is a no-op. The trailing space is emitted with a `{{ "{{ \" \" }}" }}` template expression instead of typed, because the trailing-whitespace pre-commit hook strips real ones and would silently reintroduce the drift.

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

Note the prettier hook uses `types_or`, not `types` -- pre-commit ANDs `types`, so the original `types: [json, yaml, markdown]` matched nothing and the hook silently never ran. Chezmoi templates are unaffected either way: a `.json.tmpl` is not detected as JSON.

## Theming

Single source of truth: `[data.theme]` in `chezmoi.toml` (Synthwave84 palette). Templates reference colors as `{{ .theme.bg }}`, `{{ .theme.accent }}`, etc. Applied to: fzf (`tools.zsh.tmpl`), Starship (`starship.toml.tmpl`), Hammerspoon alerts. Static theme files in `config/theme/synthwave84.toml` for tools that can't use chezmoi templates.

**Two variants.** `[data.theme]` is the base palette (Ghostty, tmux, fzf, Starship, btop, yazi). `[data.theme.soft]` is the lower-contrast **Synthwave84 Soft** variant that Zed uses, and it is the only block carrying syntax roles (`keyword`, `string`, `function`, `type`, ...) plus diagnostic and git colors. Emacs consumes `{{ .theme.soft.* }}` for UI and syntax, but reuses the base `{{ .theme.* }}` ANSI keys for terminal faces -- Zed's Soft variant leaves `terminal.ansi.*` at base values, so shell buffers match Ghostty exactly.

Authoritative source for both is the shipped Zed theme JSON (`~/Library/Application Support/Zed/extensions/installed/synthwave84/themes/synthwave84.json`), not `config/theme/synthwave84.toml`, which had drifted on `keyword` and `type`.

## Emacs

Vanilla Emacs 31 (`emacs-plus@31`) at `~/.config/emacs`, source `home/private_dot_config/emacs/`. Runs as a daemon under `brew services`; `e` and `eg` (in `aliases/dev.zsh`) open terminal and GUI frames. `EDITOR` stays `nvim`.

`31.0.91` is a **pretest** off the `emacs-31` branch, not a release -- the tap's `emacs-plus@32` (`32.0.50`) is master, not a newer stable. The tap is untrusted by default under current Homebrew, so a fresh machine needs `brew trust d12frosted/emacs-plus` before the formula will even load.

Layout: `early-init.el.tmpl` (pre-frame), `init.el`, `lisp/droo-{defaults,ui,completion,git,lang,lsp}.el`, `themes/synthwave84-soft-theme.el.tmpl`, `banner.txt`. Only the two `.tmpl` files interpolate -- colors live solely in the theme.

Six things that are easy to get wrong:

- **Upgrading the formula does not change which Emacs runs.** `emacs-plus`'s `bin/emacs` is a 5-line wrapper that execs the first of `/Applications/Emacs.app`, `~/Applications/Emacs.app`, then its own keg. The `brew services` block runs that wrapper, so with a stale `/Applications/Emacs.app` the `@31` service happily launches Emacs 30 -- `emacs --version` reports the old version from the new keg, which reads like a broken build. Replace the app bundle too (`ditto <keg>/Emacs.app /Applications/Emacs.app`), then `brew unlink emacs-plus@<old> && brew link emacs-plus@<new>`.
- **A major-version upgrade invalidates every `.elc`.** `define-minor-mode` expands differently across versions, so packages compiled by the old Emacs fail at runtime with things like `Symbol's value as variable is void: corfu-mode--set-explicitly`. Fix with `package-recompile-all` (not `byte-recompile-directory`, which has no package load-path in `-Q` and fails most files):
  `emacs --batch -l ~/.config/emacs/early-init.el --eval '(progn (require (quote package)) (package-initialize) (package-recompile-all))'`
  Tree-sitter grammars survive a library bump and do not need rebuilding; `make emacs-grammars` reports them "already available", which is itself a load test.
- **`~/.emacs.d` silently wins.** `startup--xdg-or-homedot` (`startup.el`) returns `~/.emacs.d` whenever that directory merely _exists_ -- it never checks for an `init.el`. If it reappears, the entire XDG config is ignored with no error. `make doctor` fails on this, and `setup-emacs.sh` offers to trash it.
- **Runtime state must stay out of the config tree.** `~/.config/emacs` is chezmoi-managed, so anything Emacs writes there becomes `chezmoi verify` drift. `early-init.el` redirects `package-user-dir`, the eln cache, `custom-file`, and grammars to XDG data/cache/state. This is why no `home/.chezmoiignore` was needed -- adding one would newly activate as chezmoi's real ignore file.
- **The daemon does not inherit mise.** mise activates from `.zshrc`, which `exec-path-from-shell -l` never sources, so mise-managed servers (`ruff`, `rust-analyzer`) are invisible. `droo-defaults.el` adds `~/.local/share/mise/shims` to `exec-path` explicitly.
- **Language modes and eglot are gated.** `droo-lang.el` only remaps a major mode when its tree-sitter grammar is present, and `droo-lsp.el` only hooks `eglot-ensure` when the server binary is on `PATH` -- missing pieces degrade quietly instead of erroring. Both decide at load time, so **restart the daemon after `make emacs-grammars`** or installing a server.

Adding a language: add the grammar to `treesit-language-source-alist` and the mode to `auto-mode-alist` (or `major-mode-remap-alist`) in `droo-lang.el`, add the server to `droo/eglot-servers` in `droo-lsp.el`, then `make emacs-grammars && make emacs-restart`.

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

| Server       | Flag           | Transport  | Notes                                                                                             |
| ------------ | -------------- | ---------- | ------------------------------------------------------------------------------------------------- |
| context7     | always on      | stdio      | Library docs via npx                                                                              |
| blockscout   | always on      | http       | Blockchain data queries                                                                           |
| coingecko    | `coingecko`    | http       | Crypto market data                                                                                |
| digest       | `digest`       | stdio      | Multi-platform activity digest                                                                    |
| recall       | `recall`       | stdio      | Knowledge capture/retrieval (FTS5)                                                                |
| autoresearch | `autoresearch` | stdio      | Autonomous experiment runner                                                                      |
| watchdog     | `watchdog`     | stdio      | Repo health monitor                                                                               |
| prepper      | `prepper`      | stdio      | Pre-session context builder                                                                       |
| sentinel     | `sentinel`     | stdio      | On-chain contract monitor                                                                         |
| patchbot     | `patchbot`     | stdio      | Polyglot dependency updater                                                                       |
| signoz       | `signoz`       | stdio      | Primary observability. API key from 1Password at runtime                                          |
| regen        | `regen`        | stdio      | Fluidify Regen incidents; wrapper injects `regen_url` (+ optional cookie). Correlates with signoz |
| datadog      | `datadog`      | http/OAuth | Disabled fallback (`datadog = false`). us5.datadoghq.com, no secrets                              |
| sentry       | `sentry`       | http/OAuth | mcp.sentry.dev, no secrets                                                                        |

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

**Name clashes: `skills-extra/` wins in both hosts.** chezmoi never prunes an archive external, so `~/.agents/skills/` can keep serving a stale copy of a skill that has since moved to `skills-extra/`. Raxol resolves this via `skills_external_dirs: ["~/.agents/skills", "~/.agents/skills-extra"]` -- `Skills.Store` scans in order and later `:ets.insert` calls overwrite earlier ones, so the **last** root wins. `run_after_sync-skills.sh` links the **first** root, so its `SKILL_ROOTS` is ordered `skills-extra` then `skills` to reach the same answer. Changing either without the other silently desyncs the two hosts.

One further asymmetry: Raxol globs `**/SKILL.md` (any depth) while the sync script only looks one level down. No skill is nested today, so both index the same set -- but a nested `SKILL.md` would appear in Raxol and not in Claude Code.

**Skill accounting** (re-derive with `find -L ~/.agents/skills ~/.agents/skills-extra -name SKILL.md`, don't trust this prose):

| Source                     | Count  | Notes                                                                               |
| -------------------------- | ------ | ----------------------------------------------------------------------------------- |
| agent-skills `skills/`     | 59     | upstream also ships one empty placeholder dir with no `SKILL.md`, which never loads |
| `skills-extra/` (vendored) | 2      | `virtuals-protocol-acp`, `hf-cli` (the latter originally installed by the `hf` CLI) |
| **loaded by Claude Code**  | **61** | symlinks in `~/.claude/skills/`                                                     |

**Code pattern skills** -- language-specific examples and idioms:

| Skill          | Triggers on                                                                |
| -------------- | -------------------------------------------------------------------------- |
| claude-api     | `anthropic` imports, SDK usage                                             |
| droo-stack     | Elixir, TS, Go, Rust, C, Zig, Python, Lua, Shell, Noir, Chezmoi            |
| raxol          | Raxol TUI/agent imports, headless/MCP tools                                |
| raxol-payments | :raxol_payments/:raxol_earn, Xochi/Riddler, agent wallets, ACP jobs        |
| raxol-symphony | :raxol_symphony, tracker-driven coding-agent orchestration                 |
| design-ux      | Component design, layout, tokens, motion, accessibility, TUI aesthetics    |
| nix            | `.nix` files, flakes, NixOS, Home Manager, agent-skills packaging, rigup   |
| native-code    | NIFs (C/Rust), SIMD (Zig), erl_nif.h, Rustler, BEAM native boundary        |

**Web3 skills** -- blockchain development, auditing, and data:

| Skill            | Triggers on                                                                |
| ---------------- | -------------------------------------------------------------------------- |
| ethskills        | Ethereum tooling, EIP/ERC standards, framework selection                   |
| solidity-auditor | `.sol` files, foundry.toml, auditing, security review                      |
| noir             | `.nr` files, Nargo.toml, ZK circuits, Aztec contracts/security/e2e testing |
| blockscout       | On-chain data queries, contract state, token balances, ENS, NFT holdings   |
| coingecko        | Token prices, market caps, DEX pools, trending tokens, price history       |

**MCP-companion skills** -- reference docs for MCP agent tools:

| Skill        | Triggers on                                                   |
| ------------ | ------------------------------------------------------------- |
| autoresearch | Experiment status, "run another iteration", `/autoresearch`   |
| patchbot     | Outdated dependencies, "update deps", `/patchbot`             |
| prepper      | Project briefings, "catch me up", "prep me", `/prepper`       |
| sentinel     | Contract monitoring, on-chain alerts, suspicious transactions |
| watchdog     | Repo health, stale PRs, CI status, security advisories        |

**Workflow skills** (41 total) -- architect, code-review, tdd, focused-fix, adversarial-reviewer, prd-to-plan, prd-to-issues, release, frontend-slop-audit, and more. Each has a SKILL.md with trigger conditions.

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
