# Global Claude Code Preferences

## Workflow Philosophy

- Brainstorm before implementing non-trivial features - clarify requirements first
- Don't declare victory with loose ends - finish what you start
- Systematic debugging over ad-hoc fixes - understand root cause
- Evidence over claims - verify before declaring success
- YAGNI - don't build for hypothetical future requirements

## General Preferences

- avoid emojis, use ascii instead
- never use mocks in tests unless explicitly requested
- only write code idiomatic to the language being used
- no coauthored by claude in commits
- terse commit messages (50 char subject max)
- prefer explicit over implicit
- write self-documenting code with clear naming
- keep functions small and focused

## Elixir

- use functional patterns idiomatic to elixir
- avoid imperative patterns where functional alternatives exist
- prefer pattern matching and pipe operators
- use Raxol for TUI applications
- use ExUnit for testing with descriptive test names
- prefer with for complex pattern matching chains

## TypeScript

- prefer functional patterns (map/filter/reduce, pure functions, immutability)
- never swallow errors - always log or rethrow, no empty catch blocks
- ensure adequate logging for debugging and observability
- use strict TypeScript settings
- prefer zod for runtime validation

## Shell/Bash

- use set -e for scripts
- shellcheck compliant always
- use Typer (Python) for complex CLI tools
- prefer functions over complex one-liners
- quote variables properly ("$var" not $var)
- use [[ ]] over [ ] for conditionals
- prefer printf over echo for portability

## Go

- prefer table-driven tests
- use error wrapping with fmt.Errorf and %w
- keep interfaces small (1-3 methods)
- accept interfaces, return structs

## Lua

- use local variables
- prefer metatables for OOP patterns
- use LuaLS annotations for type hints

## Rust

- prefer Result over panic
- use clippy recommendations
- derive traits liberally (Debug, Clone, PartialEq)
- use thiserror for library errors, anyhow for applications

## Python

- type hints for function signatures
- prefer pathlib over os.path
- use Typer for CLI applications
- use pydantic for data validation
- prefer f-strings for formatting

## Chezmoi Encrypted Files

Dotfiles managed by chezmoi with age encryption. To edit encrypted templates:

```bash
# 1. Decrypt to temp file
age -d -i ~/.config/chezmoi/age_key.txt <source_file> > /tmp/edit.txt

# 2. Edit /tmp/edit.txt

# 3. Re-encrypt in place
age -r "age1pf2v9lee0rtqp8ur4tatk5w0kpp45t9d7st7zakdlsv7ykdk2ewqacwwjp" -o <source_file> /tmp/edit.txt

# 4. Verify: chezmoi diff <target_path>
# 5. Clean up: rm /tmp/edit.txt
```

- `chezmoi re-add` does NOT work for encrypted templates
- `chezmoi edit` opens an interactive editor (not usable non-interactively)
- source paths: `chezmoi source-path <target>` to find the encrypted file
- always verify with `chezmoi diff` after re-encrypting

## Claude Code Plugins

Currently installed (via settings.json):
- `rust-analyzer-lsp@claude-plugins-official` - Rust LSP integration
- `lua-lsp@claude-plugins-official` - Lua LSP integration

Optional plugins (install interactively via `/plugin`):

```bash
# Official plugins marketplace (PR review, frontend design)
/plugin marketplace add anthropics/claude-plugins-official

# Superpowers - workflow discipline (brainstorming, systematic debugging, TDD)
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

Superpowers skills (if installed):
- `/superpowers:brainstorm` - Refines ideas through questioning before implementation
- `/superpowers:systematic-debugging` - Structured 4-phase root cause analysis
