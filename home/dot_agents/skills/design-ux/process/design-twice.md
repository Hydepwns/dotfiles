---
title: Design It Twice
impact: HIGH
impactDescription: Design methodology prevents wasted implementation effort
tags: process, methodology, design-twice, divergent, synthesis, agent
---

# Design It Twice

Adapted from John Ousterhout's "A Philosophy of Software Design" and mattpocock's agent skill. When facing a non-trivial design decision, generate two divergent designs before committing to one.

## The Method

1. **Gather requirements** -- scope, users, operations, constraints, error states
2. **Generate two designs** with different optimization targets
3. **Compare** across dimensions: simplicity, generality, efficiency, surface area
4. **Synthesize** the best elements into a final design
5. **Implement** only after alignment

## Agent Workflow

When asked to build a UI, do not jump straight to implementation.

INCORRECT:

```
User: "Build a settings page"

Agent: *immediately writes 200 lines of JSX*
  <SettingsPage>
    <Tabs>
      <Tab label="General">...</Tab>
      <Tab label="Notifications">...</Tab>
      ...
    </Tabs>
  </SettingsPage>
```

CORRECT:

```
User: "Build a settings page"

Agent: "I see two approaches. Let me sketch both:

  Design A -- Tabbed Sidebar (optimizes for navigation):
  ┌──────────┬──────────────────────────┐
  │ General  │ Display Name             │
  │ Notify   │ [Andrew]                 │
  │ Security │                          │
  │ Billing  │ Email                    │
  │ API Keys │ [andrew@example.com]     │
  │          │                          │
  │          │ [Save Changes]           │
  └──────────┴──────────────────────────┘
  + Quick access to any section
  + Scales to many sections
  - More complex component tree
  - Settings are isolated (hard to compare across sections)

  Design B -- Single Scrollable Form (optimizes for simplicity):
  ┌──────────────────────────────────────┐
  │ Settings                             │
  │                                      │
  │ ── General ──────────────────────── │
  │ Display Name: [Andrew]               │
  │ Email: [andrew@example.com]          │
  │                                      │
  │ ── Notifications ────────────────── │
  │ Email notifications: [x]            │
  │ Weekly digest: [x]                  │
  │                                      │
  │ [Save All Changes]                   │
  └──────────────────────────────────────┘
  + Simple: one component, one scroll
  + All settings visible, easy to compare
  - Long page if many settings
  - No deep linking to specific sections

  Which direction, or should I combine elements from both?"
```

## Requirements Gathering Checklist

Before designing, answer these:

- **Who uses this?** (admin, end user, developer, public)
- **What data flows through it?** (read-heavy, write-heavy, mixed)
- **How many items/options/fields?** (5 settings vs 50 settings changes the design)
- **What are the error states?** (validation, network failure, permissions)
- **What are the edge cases?** (empty state, max data, long strings, missing fields)
- **What is the performance budget?** (instant, acceptable latency, background processing)
- **What devices/contexts?** (desktop only, mobile-first, terminal, embedded)

## Comparison Dimensions

When comparing two designs, evaluate on these axes:

| Dimension | Question |
|-----------|----------|
| **Simplicity** | How many concepts must the user learn? |
| **Generality** | Does it handle edge cases without special-casing? |
| **Efficiency** | How many interactions to complete the common task? |
| **Surface area** | How many components/props/states to maintain? |
| **Depth** | How much complexity is hidden behind a simple interface? |
| **Accessibility** | Which is easier to make keyboard/screen-reader accessible? |

A good design is a "deep module": minimal surface area hiding significant complexity.

## When NOT to Design Twice

Not every change needs this process. Skip it when:

- Fixing alignment, spacing, or color
- Changing copy or labels
- Adding a field to an existing form
- The pattern already exists elsewhere in the app (follow it)

**Threshold**: If the change affects >3 components or introduces a new pattern, design twice. If it is a variation of an existing pattern, just build it.

## Synthesis Patterns

Common ways to combine two designs:

- **A's structure, B's interaction model** -- e.g., tabbed layout but with inline editing from the scrollable version
- **A as default, B as advanced mode** -- e.g., simple form by default, power-user view toggleable
- **A for desktop, B for mobile** -- different designs for different contexts, sharing the same data layer
- **A's component API, B's visual design** -- compound components from design A with the dense layout from design B
