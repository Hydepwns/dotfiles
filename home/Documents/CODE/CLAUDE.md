# CODE Directory Conventions

Shared conventions for all projects in this directory. Project-level CLAUDE.md files override these where specified.

## Commit Style

- 50 char subject max, imperative mood ("Add feature" not "Added feature")
- No "Co-Authored-By" lines
- No conventional commit prefixes unless project specifies them
- Commit the minimum necessary - avoid bundling unrelated changes

## Pull Requests

- Short title (<70 chars), details in body
- Use `gh pr create --body-file` for multiline descriptions (preserves newlines)
- Include "Manual testing" checklist section
- No time estimates in descriptions

## Code Review

- Fix what's broken, don't refactor adjacent code
- Don't add comments/docstrings to unchanged code
- Don't "improve" code style in unrelated areas

## Testing

- Never use mocks unless explicitly requested
- Tests should be deterministic - no sleeps, no real network calls
- Prefer integration tests over unit tests for business logic
- Test the public interface, not implementation details

## Error Handling

- Never swallow errors (empty catch blocks, bare `rescue`, `|| true` without reason)
- Log or rethrow - pick one
- Include context in error messages

## Language Detection

Detect project language by these markers and apply corresponding conventions from global CLAUDE.md:

| Marker | Language | Key conventions |
|--------|----------|-----------------|
| `mix.exs` | Elixir | Pattern matching, pipes, `with` chains, ExUnit |
| `Cargo.toml` | Rust | Result over panic, clippy, thiserror/anyhow |
| `pyproject.toml` | Python | Type hints, pathlib, Typer for CLI, pydantic |
| `package.json` | TypeScript/JS | Strict TS, zod, functional patterns |
| `go.mod` | Go | Table-driven tests, small interfaces, error wrapping |
| `*.lua`, `.luarc.json` | Lua | Local vars, LuaLS annotations, metatables |
| `justfile` | Just | Preferred over Makefile for non-chezmoi projects |
| `Makefile` | Make | Used for chezmoi/dotfiles projects |

## Elixir Projects (Common Patterns)

Most Elixir projects in this directory follow:

```bash
mix setup              # deps.get, db create/migrate, assets
mix test               # run tests (creates sandbox DB)
mix precommit          # compile --warnings-as-errors, format, test
mix format --check-formatted
```

GenServers are typically disabled in test config via `config :app, start_*: false`.

Use `Req` for HTTP clients (not HTTPoison/Tesla).

## Rust Projects

```bash
cargo check            # fast type checking
cargo clippy           # lint
cargo test             # run tests
cargo fmt --check      # format check
```

## Python Projects

```bash
just check             # format, lint, typecheck, test (if justfile exists)
uv run pytest          # tests
uv run ruff check      # lint
uv run ruff format     # format
```

Use `uv` for package management, `msgspec` for fast JSON, `structlog` for logging.

## Infrastructure Projects

Ansible projects (`ansible-*`):
- Roles in `roles/`, playbooks at root
- Use `ansible-lint` before commits
- Molecule for testing where available

Terraform projects:
- `terraform fmt -check`
- `terraform validate`

## Git Workflow

- Feature branches off `main`
- Rebase preferred over merge for feature branches
- Never force push to `main`/`master`
- Clean up merged branches locally

## Security

- Never commit secrets, API keys, credentials
- Use 1Password CLI (`op`) or environment variables
- Check for accidental secret commits before pushing
