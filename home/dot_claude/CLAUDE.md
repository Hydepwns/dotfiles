# Global Claude Code Preferences

- avoid emojis, use ascii instead
- never use mocks in tests unless explicitly requested
- only write code idiomatic to the language being used
- no coauthored by claude in commits

## Elixir
- use functional patterns idiomatic to elixir
- avoid imperative patterns where functional alternatives exist
- prefer pattern matching and pipe operators

## TypeScript
- prefer functional patterns (map/filter/reduce, pure functions, immutability)
- never swallow errors - always log or rethrow, no empty catch blocks
- ensure adequate logging for debugging and observability
- use strict TypeScript settings

## General
- prefer explicit over implicit
- write self-documenting code with clear naming
- keep functions small and focused
