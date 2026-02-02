# Global Claude Code Preferences

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
