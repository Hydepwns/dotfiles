---
title: Design Tokens
impact: HIGH
impactDescription: Token inconsistency creates visual chaos and maintenance burden
tags: tokens, design-system, dark-mode, css-variables, tailwind, theming
---

# Design Tokens

## Three-Tier Token Hierarchy

Primitive tokens (raw values) -> semantic tokens (purpose) -> component tokens (specific usage). Components only reference semantic or component tokens, never primitives.

INCORRECT:

```tsx
// Raw hex values scattered through components
<div style={{ background: "#1a1a2e", color: "#e2e8f0", padding: "16px" }}>
  <h2 style={{ color: "#ff7edb", fontSize: "20px" }}>Title</h2>
  <p style={{ color: "#94a3b8" }}>Description</p>
</div>
```

CORRECT:

```css
/* Tier 1: Primitive tokens (defined once, referenced by semantic tokens) */
:root {
  --gray-900: #1a1a2e;
  --gray-100: #e2e8f0;
  --gray-400: #94a3b8;
  --pink-400: #ff7edb;
}

/* Tier 2: Semantic tokens (purpose-driven, theme-switchable) */
:root {
  --color-bg-primary: var(--gray-900);
  --color-text-primary: var(--gray-100);
  --color-text-muted: var(--gray-400);
  --color-accent: var(--pink-400);
}

/* Tier 3: Component tokens (optional, for complex components) */
:root {
  --card-bg: var(--color-bg-primary);
  --card-border: var(--color-text-muted);
}
```

```tsx
// Components reference semantic names only
<div className="bg-surface text-foreground p-4">
  <h2 className="text-accent text-xl">Title</h2>
  <p className="text-muted">Description</p>
</div>
```

## Dark/Light Mode via Semantic Tokens

Theme switching happens at the token layer, not in component logic.

INCORRECT:

```tsx
// Theme logic in every component
function Card({ children }: { children: React.ReactNode }) {
  const { isDark } = useTheme();
  return (
    <div className={isDark ? "bg-gray-900 text-gray-100 border-gray-700" : "bg-white text-gray-900 border-gray-200"}>
      {children}
    </div>
  );
}
```

CORRECT:

```css
/* Token swap at root -- components are theme-unaware */
:root, [data-theme="dark"] {
  --color-bg-primary: #1a1a2e;
  --color-text-primary: #e2e8f0;
  --color-border: #334155;
}

[data-theme="light"] {
  --color-bg-primary: #fafafa;
  --color-text-primary: #1a1a2e;
  --color-border: #d1d5db;
}
```

```tsx
// Component has zero theme awareness
function Card({ children }: { children: React.ReactNode }) {
  return (
    <div className="bg-surface text-foreground border border-default">
      {children}
    </div>
  );
}
```

## Spacing Scale

All spacing derives from a base unit. No arbitrary pixel values.

INCORRECT:

```css
/* Arbitrary values -- no system, no rhythm */
.header { padding: 13px 22px; gap: 11px; }
.card { margin: 17px; padding: 9px; }
.sidebar { padding: 15px; gap: 7px; }
```

CORRECT:

```css
/* Geometric scale from 4px base */
:root {
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-5: 1.5rem;   /* 24px */
  --space-6: 2rem;     /* 32px */
  --space-7: 3rem;     /* 48px */
  --space-8: 4rem;     /* 64px */
}

.header { padding: var(--space-2) var(--space-5); gap: var(--space-3); }
.card { margin: var(--space-4); padding: var(--space-3); }
```

In Tailwind: use the default spacing scale (`p-1` through `p-16`) which maps to a 4px base. Avoid arbitrary values (`p-[13px]`).

## Typography Tokens

Type scale, weights, and line-heights defined as tokens, not ad-hoc values.

INCORRECT:

```css
h1 { font-size: 28px; line-height: 1.1; font-weight: 800; }
h2 { font-size: 22px; line-height: 1.3; font-weight: 700; }
p { font-size: 15px; line-height: 1.4; }
.small { font-size: 11px; line-height: 1.2; }
```

CORRECT:

```css
:root {
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.25rem;    /* 20px */
  --text-xl: 1.5rem;     /* 24px */
  --text-2xl: 1.875rem;  /* 30px */
  --text-3xl: 2.25rem;   /* 36px */

  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;
}

h1 { font-size: var(--text-2xl); line-height: var(--leading-tight); font-weight: 600; }
h2 { font-size: var(--text-xl); line-height: var(--leading-tight); font-weight: 600; }
p { font-size: var(--text-base); line-height: var(--leading-normal); }
.small { font-size: var(--text-xs); line-height: var(--leading-normal); }
```

## Token Naming Conventions

Names describe purpose, not appearance.

INCORRECT:

```css
/* Named by appearance -- breaks when themes change */
--dark-blue: #1a1a2e;
--light-gray: #e2e8f0;
--pink: #ff7edb;
--big-text: 24px;
--thin-border: 1px;
```

CORRECT:

```css
/* Named by purpose -- stable across themes */
--color-bg-primary: #1a1a2e;
--color-text-primary: #e2e8f0;
--color-accent: #ff7edb;
--text-xl: 1.5rem;
--border-width-default: 1px;
```

## Tailwind Token Integration

Map design tokens to Tailwind config so utility classes and tokens stay in sync.

INCORRECT:

```js
// tailwind.config.js -- using defaults with scattered overrides
module.exports = {
  theme: {
    extend: {
      colors: {
        'special-bg': '#1a1a2e',
        'my-accent': '#ff7edb',
      }
    }
  }
}
```

CORRECT:

```js
// tailwind.config.js -- systematic token mapping
module.exports = {
  theme: {
    colors: {
      surface: 'var(--color-bg-primary)',
      foreground: 'var(--color-text-primary)',
      muted: 'var(--color-text-muted)',
      accent: 'var(--color-accent)',
      border: {
        DEFAULT: 'var(--color-border)',
      },
      // Primitive palette available but discouraged in components
      neutral: {
        900: '#1a1a2e',
        800: '#1e293b',
        700: '#334155',
        400: '#94a3b8',
        100: '#e2e8f0',
      }
    },
    spacing: {
      // Maps to --space-N tokens
      1: '0.25rem',
      2: '0.5rem',
      3: '0.75rem',
      4: '1rem',
      5: '1.5rem',
      6: '2rem',
      8: '3rem',
      10: '4rem',
    }
  }
}
```
