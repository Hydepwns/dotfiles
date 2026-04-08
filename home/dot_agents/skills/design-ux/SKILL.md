---
name: design-ux
description: >
  UI/UX design patterns and design system architecture.
  TRIGGER when: working on component design, layout/grid decisions, design tokens,
  color palettes, typography, accessibility (WCAG), responsive design, TUI aesthetics,
  or creating DESIGN.md documentation. Covers React, Tailwind CSS, terminal UI, and
  mobile patterns with a monospace-first, constraint-based design philosophy.
  DO NOT TRIGGER when: writing React/TypeScript code logic (use droo-stack skill),
  building Raxol TUI framework features (use raxol skill), or working with
  CSS-in-JS runtime concerns (this skill covers design decisions, not runtime).
metadata:
  author: hydepwns
  version: "1.0.0"
  tags: design, ux, ui, tailwind, react, accessibility, tokens, typography, tui
---

# design-ux

Constraint-based design. Monospace-first. Every pixel earns its place. Zero layout shift. The terminal is the design system's origin; web and mobile are projections from it.

Design decisions flow from constraints, not decoration. Start from the character grid, add only what communicates. If a visual element does not serve information hierarchy, remove it.

## When to Use

- Component architecture and composition patterns
- Design token systems and theming
- Typography, color, and spacing decisions
- Accessibility and WCAG compliance
- Layout and grid systems
- Terminal UI design principles
- Mobile/responsive design
- Design documentation (DESIGN.md)

## When NOT to Use

- **Code-level patterns** (TypeScript, React hooks, error handling) -- use `droo-stack`
- **Raxol framework API** (TEA agents, headless sessions, MCP tools) -- use `raxol`
- **Claude/Anthropic SDK integration** -- use `claude-api`
- **Solidity/smart contract design** -- use `solidity-audit`

## Reading Guide

| Working on | Read |
|-----------|------|
| Design philosophy, constraint-based thinking | `shared/principles.md` |
| Accessibility, WCAG, keyboard, screen readers | `shared/accessibility.md` |
| Design token systems, dark/light mode | `shared/design-tokens.md` |
| React component architecture, composition | `web/react-components.md` |
| Tailwind utility patterns, DROO-flavored config | `web/tailwind-patterns.md` |
| Grid, spacing, responsive breakpoints | `web/layout-grid.md` |
| Type scale, font stacks, vertical rhythm | `web/typography.md` |
| Color palettes, semantic tokens, contrast | `web/color-systems.md` |
| Terminal UI layout, box-drawing, constraints | `terminal/tui-layout.md` |
| Monospace design language, density, ASCII | `terminal/terminal-aesthetic.md` |
| Mobile/responsive/touch, native patterns | `mobile/responsive-native.md` |
| "Design It Twice" agent methodology | `process/design-twice.md` |
| DESIGN.md template, living documentation | `process/design-docs.md` |

## See also

- `droo-stack` -- for code-level patterns (TypeScript, React hooks, error handling)
- `raxol` -- for Raxol TUI framework API (TEA agents, headless sessions)
- `ethskills` -- for Ethereum/dApp ecosystem tooling

## Key Conventions

- **Terminal is origin**: Design for the character grid first, then project to pixel-based media
- **Semantic over literal**: Use token names (`text-foreground`, `bg-surface`), never raw values in components
- **Composition over configuration**: Small, composable components beat mega-components with boolean props
- **Constraint-based sizing**: Prefer `min/max/fit-content` over fixed pixel widths
- **Monospace default**: Sans-serif is the exception, not the rule
