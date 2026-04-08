---
title: Color Systems
impact: MEDIUM
impactDescription: Color reinforces hierarchy but rarely breaks functionality
tags: color, palette, semantic, contrast, dark-mode, terminal, ansi
---

# Color Systems

## Systematic Palette Structure

A color system has: neutral scale (8-10 steps), 2-3 accent colors, and semantic mappings (success/warning/error/info). Do not pick colors per-component.

INCORRECT:

```css
/* Ad-hoc colors: no system, impossible to theme */
.header { background: #2d2d3f; }
.sidebar { background: #1a1b2e; }
.card { background: #252538; border-color: #3a3a50; }
.button-primary { background: #6366f1; }
.button-danger { background: #ef4444; }
.link { color: #818cf8; }
.success-text { color: #22c55e; }
```

CORRECT:

```css
/* Systematic palette: neutral scale + accents + semantics */
:root {
  /* Neutral scale (10 steps, darkest to lightest) */
  --neutral-950: #0a0a14;
  --neutral-900: #1a1a2e;
  --neutral-800: #1e293b;
  --neutral-700: #334155;
  --neutral-600: #475569;
  --neutral-500: #64748b;
  --neutral-400: #94a3b8;
  --neutral-300: #cbd5e1;
  --neutral-200: #e2e8f0;
  --neutral-100: #f1f5f9;

  /* Accent (1 primary, 1 secondary) */
  --accent-primary: #ff7edb;
  --accent-secondary: #72f1b8;

  /* Semantic (derived from accent or functional colors) */
  --color-error: #f87171;
  --color-warning: #fbbf24;
  --color-success: #34d399;
  --color-info: #60a5fa;
}
```

## Semantic Over Literal

Components reference semantic token names, never color-scale positions or hex values.

INCORRECT:

```tsx
// Literal color references: break on theme change
<div className="bg-gray-900 text-gray-100 border-gray-700">
  <span className="text-blue-600">Link</span>
  <span className="text-red-500">Error</span>
</div>
```

CORRECT:

```tsx
// Semantic references: stable across themes
<div className="bg-surface text-foreground border-default">
  <span className="text-accent">Link</span>
  <span className="text-error">Error</span>
</div>
```

## Terminal-Origin Palette (DROO Flavor)

The color system starts from ANSI 16-color conventions, then extends to full web use. Dark background is the default.

```
ANSI Base 16 (terminal origin):
  Black:   #1a1a2e    Red:     #f87171
  Green:   #34d399    Yellow:  #fbbf24
  Blue:    #60a5fa    Magenta: #ff7edb
  Cyan:    #72f1b8    White:   #e2e8f0

  Bright variants: +20% lightness for each

Web extension:
  Surface layers:  neutral-950 -> neutral-900 -> neutral-800
  Text hierarchy:  neutral-200 (primary) -> neutral-400 (muted) -> neutral-600 (disabled)
  Accent:          magenta (primary action) -> cyan (secondary/success)
  Borders:         neutral-700 (default) -> neutral-600 (hover) -> accent (focus)
```

INCORRECT:

```css
/* Starting from a "web" palette and adding terminal colors as afterthought */
:root {
  --primary: #3b82f6;   /* Web blue */
  --bg: white;
  --text: black;
}
.terminal-view {
  --bg: #000;           /* Bolted-on terminal mode */
  --text: #0f0;
}
```

CORRECT:

```css
/* Terminal palette is the origin; light mode is the projection */
:root {
  --bg: #1a1a2e;         /* Terminal black */
  --fg: #e2e8f0;         /* Terminal white */
  --accent: #ff7edb;     /* Terminal magenta */
  --success: #72f1b8;    /* Terminal cyan */
}

[data-theme="light"] {
  --bg: #f1f5f9;
  --fg: #1a1a2e;
  --accent: #c026d3;     /* Darkened magenta for light bg contrast */
  --success: #059669;    /* Darkened cyan */
}
```

## Contrast Validation

Validate contrast ratios programmatically. Do not rely on visual inspection.

INCORRECT:

```tsx
// "Looks fine on my monitor" approach
<p style={{ color: "#6b7280", background: "#374151" }}>
  {/* 2.6:1 ratio -- fails WCAG AA */}
  Muted text
</p>
```

CORRECT:

```tsx
// Validated against WCAG AA (4.5:1 normal text, 3:1 large text)
<p className="text-muted bg-surface">
  {/* --color-text-muted: #94a3b8 on --color-bg-primary: #1a1a2e = 6.4:1 */}
  Muted text
</p>
```

Integrate contrast checks:
- Tailwind: `tailwindcss-contrast` plugin or manual audit
- CI: `axe-core` or `pa11y` in test pipeline
- Design time: browser devtools contrast picker

## Color for State, Not Decoration

Color communicates state changes. Do not use color purely for visual interest.

INCORRECT:

```tsx
// Color as decoration: gradient that adds no information
<div className="bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 p-6 rounded-xl">
  <h2 className="text-white">Dashboard</h2>
</div>
```

CORRECT:

```tsx
// Color as state: border communicates status
<div className={cn(
  "border-l-4 bg-surface p-4 font-mono",
  status === "healthy" && "border-success",
  status === "degraded" && "border-warning",
  status === "down" && "border-error",
)}>
  <h2 className="text-foreground">{serviceName}</h2>
  <span className="text-muted">{statusMessage}</span>
</div>
```
