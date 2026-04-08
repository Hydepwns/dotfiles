---
title: Design Documentation
impact: MEDIUM
impactDescription: Documentation ensures design intent survives implementation
tags: process, design-doc, documentation, template, design-md
---

# Design Documentation

## When to Create a DESIGN.md

Any project with >1 contributor or >5 UI components. Solo scripts, CLIs without visual UI, and pure API backends do not need one.

## DESIGN.md Template

Six sections. Keep it under 200 lines. Reference token files rather than duplicating values.

```markdown
# DESIGN.md

## Visual Theme

Constraint-based, monospace-first. Terminal aesthetic as the design origin.
Dark mode default. Light mode is a projection, not the primary design target.

Font stack: Monaspace Neon (primary), Monaspace Argon (prose), Monaspace Krypton (data).
Sans-serif: General Sans (primary), Satoshi (fallback).

## Color Palette

Reference `tokens/colors.css` for full definitions.

| Token          | Dark            | Light           | Usage                  |
|----------------|-----------------|-----------------|------------------------|
| `--bg`         | #1a1a2e         | #f1f5f9         | Page background        |
| `--fg`         | #e2e8f0         | #1a1a2e         | Primary text           |
| `--muted`      | #94a3b8         | #64748b         | Secondary text         |
| `--accent`     | #ff7edb         | #c026d3         | Primary actions        |
| `--secondary`  | #72f1b8         | #059669         | Success, secondary     |
| `--border`     | #334155         | #d1d5db         | Borders, dividers      |
| `--error`      | #f87171         | #dc2626         | Errors                 |
| `--warning`    | #fbbf24         | #d97706         | Warnings               |

## Typography

Type scale: 12 / 14 / 16 / 20 / 24 / 30 / 36 (major third from 16px base).
Line height: 1.5rem baseline. All vertical spacing snaps to multiples.
Weights: 400 (body), 600 (headings). Two weights maximum.

## Key Components

Document 3-5 core components with their variants and states.

### Button
- Variants: `default`, `primary`, `destructive`, `ghost`
- Sizes: `sm` (h-8), `md` (h-10), `lg` (h-12)
- States: default, hover, active, disabled, loading

### Card
- Border: 1px `--border`, no shadow, no border-radius (constraint-based)
- Padding: `--space-4` (16px)
- No external margin (parent controls layout)

### Input
- Height: h-10 (matches button md)
- Border: 1px `--border`, focus: 2px `--accent`
- Monospace font by default

## Do's and Don'ts

Do:
- Use semantic color tokens, never raw hex in components
- Design for the worst case (truncation, missing data, errors)
- Reserve space for loading states (zero layout shift)
- Use 2-3 font sizes per view maximum
- Test with keyboard-only navigation

Don't:
- Add gradients, shadows, or rounded corners without justification
- Use more than 2 font weights
- Set fixed pixel widths on containers
- Skip heading levels (h1 -> h3)
- Remove focus indicators

## Responsive Strategy

Mobile-first. Base styles target smallest viewport.

| Breakpoint | Target     | Layout Changes              |
|------------|------------|-----------------------------|
| Base       | Mobile     | Single column, stacked      |
| `md` 768px | Tablet     | Two-column where beneficial |
| `lg` 1024px| Desktop    | Full layout, sidebar        |

Max content width: `max-w-prose` (~65ch) for text, `max-w-6xl` for data.
```

## Living Documentation

A DESIGN.md is only useful if it stays current.

INCORRECT:

```markdown
<!-- Written once, never updated -->
# DESIGN.md
Last updated: 2024-01-15

## Colors
Primary: #3b82f6
<!-- Meanwhile, the actual app uses #6366f1 -->
```

CORRECT:

```markdown
# DESIGN.md

## Color Palette
Reference: `src/tokens/colors.css` (source of truth)
<!-- This file documents intent and constraints.
     Actual values live in the token files. -->
```

Keep the DESIGN.md focused on **decisions and constraints** (why), not **current values** (what). Values change; the reasoning behind them is what needs documenting.

## Review Triggers

Update DESIGN.md when:

- Adding a new component that establishes a new pattern
- Changing the color palette or typography scale
- Adding a new breakpoint or layout pattern
- Onboarding a new contributor (they should be able to read DESIGN.md and understand the visual language)

Do NOT update for:
- Bug fixes
- Adding content to existing components
- Changing copy or labels
