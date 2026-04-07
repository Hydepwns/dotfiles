---
name: droo-stack
description: >
  Detailed coding patterns for a polyglot stack. TRIGGER when: working in
  Elixir, TypeScript, Go, Rust, Python, Lua, Shell/Bash, Noir, or chezmoi
  templates. Provides incorrect/correct examples that complement CLAUDE.md
  preferences. DO NOT TRIGGER when: working with Claude API or Anthropic SDK
  (use claude-api skill), Raxol TUI/agent framework patterns (use raxol skill),
  Solidity smart contracts (use solidity-audit skill), or ZK circuit domain
  questions (use noir skill -- this skill only covers Noir language syntax).
metadata:
  author: hydepwns
  version: "1.0.0"
  tags: elixir, typescript, go, rust, python, lua, shell, noir, chezmoi
---

# droo-stack

Concrete coding patterns for a polyglot stack. Each rule shows **Incorrect** and **Correct** examples with rationale. These complement CLAUDE.md (which sets high-level preferences) with detailed, actionable reference material.

## When to use

This skill activates contextually when working in the languages below. Read the relevant rule file for the language you're working in.

## Rules by impact

### CRITICAL

- [go-errors](rules/go-errors.md) -- Error wrapping, `errors.Is`/`errors.As`, sentinel errors
- [rust-errors](rules/rust-errors.md) -- thiserror/anyhow, `?` operator, From implementations
- [noir-patterns](rules/noir-patterns.md) -- Field vs integers, constrained/unconstrained, nargo tests

### HIGH

- [elixir-patterns](rules/elixir-patterns.md) -- `with` chains, pipes, pattern matching in function heads
- [typescript-zod](rules/typescript-zod.md) -- Zod schemas, discriminated unions, safeParse
- [typescript-patterns](rules/typescript-patterns.md) -- Functional patterns, strict mode, error handling
- [go-testing](rules/go-testing.md) -- Table-driven tests, `t.Run`, `t.Helper()`
- [rust-patterns](rules/rust-patterns.md) -- Builder pattern, derive traits, clippy, iterators
- [python-cli](rules/python-cli.md) -- Typer scaffolding, pydantic models, pathlib, pytest
- [lua-modules](rules/lua-modules.md) -- Module pattern, metatables, LuaLS annotations
- [shell-patterns](rules/shell-patterns.md) -- Traps, getopts, `[[ ]]`, quoting, `set -euo pipefail`

### MEDIUM

- [elixir-testing](rules/elixir-testing.md) -- ExUnit patterns, real dependencies over mocks
- [python-patterns](rules/python-patterns.md) -- Type hints, f-strings, async, comprehensions
- [chezmoi-templates](rules/chezmoi-templates.md) -- Whitespace trimming, conditionals, run_onchange scripts
