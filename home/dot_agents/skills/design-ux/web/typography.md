---
title: Typography
impact: HIGH
impactDescription: Typography is the primary tool for information hierarchy
tags: typography, fonts, type-scale, vertical-rhythm, monospace, font-loading
---

# Typography

## Monospace-First Stack (DROO Flavor)

Monospace is the default. Sans-serif is reserved for extended prose where proportional type aids readability.

INCORRECT:

```css
/* Sans-serif default -- treats monospace as "code only" */
body {
  font-family: "General Sans", "Satoshi", system-ui, sans-serif;
}
code, pre, .mono {
  font-family: "Monaspace Neon", monospace;
}
```

CORRECT:

```css
/* Monospace default -- sans-serif is the exception */
body {
  font-family: "Monaspace Neon", "Monaspace Argon", "Monaspace Krypton", ui-monospace, monospace;
}
article, .prose {
  font-family: "General Sans", "Satoshi", "Cabinet Grotesk", ui-sans-serif, system-ui, sans-serif;
}
```

The Monaspace family (by GitHub) has 5 variants for different contexts: Neon (general-purpose), Argon (humanist for prose-adjacent UI), Krypton (mechanical for data/tables), Radon (handwriting accent), Xenon (slab-serif for headings). Monaspace also supports "texture healing" for improved monospace readability.

The monospace default works for: dashboards, data-heavy UIs, developer tools, status displays, tables, navigation, forms. Switch to sans-serif for: blog posts, documentation, long-form content.

## Modular Type Scale

Sizes derived from a mathematical ratio, not arbitrary values. Use a 1.25 (major third) or 1.2 (minor third) ratio.

INCORRECT:

```css
/* Arbitrary sizes: no relationship between steps */
.text-tiny { font-size: 11px; }
.text-small { font-size: 13px; }
.text-normal { font-size: 15px; }
.text-medium { font-size: 18px; }
.text-big { font-size: 22px; }
.text-huge { font-size: 28px; }
```

CORRECT:

```css
/* Major third scale (1.25 ratio) from 16px base */
:root {
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px -- base */
  --text-lg: 1.25rem;    /* 20px */
  --text-xl: 1.5rem;     /* 24px */
  --text-2xl: 1.875rem;  /* 30px */
  --text-3xl: 2.25rem;   /* 36px */
}
```

In practice: use 3-4 sizes per page. If you need more than 5 distinct sizes, the hierarchy is unclear.

## Vertical Rhythm

All vertical spacing snaps to multiples of the base line-height. This creates visual rhythm and alignment across columns.

INCORRECT:

```css
/* Arbitrary line-heights and margins: no rhythm */
h1 { font-size: 2rem; line-height: 1.1; margin-bottom: 18px; }
h2 { font-size: 1.5rem; line-height: 1.3; margin-bottom: 14px; }
p { font-size: 1rem; line-height: 1.4; margin-bottom: 11px; }
ul { line-height: 1.6; margin-bottom: 22px; }
```

CORRECT:

```css
/* Base unit: 1.5rem (24px). All spacing is a multiple. */
:root { --baseline: 1.5rem; }

h1 {
  font-size: var(--text-2xl);
  line-height: calc(var(--baseline) * 2);     /* 48px -- 2 baseline units */
  margin-bottom: var(--baseline);              /* 24px */
}
h2 {
  font-size: var(--text-xl);
  line-height: calc(var(--baseline) * 1.5);   /* 36px */
  margin-bottom: var(--baseline);
}
p, ul, ol {
  font-size: var(--text-base);
  line-height: var(--baseline);                /* 24px */
  margin-bottom: var(--baseline);
}
```

## Font Weight Discipline

Use 2-3 weights maximum. More weights create noise, not hierarchy.

INCORRECT:

```css
/* Weight soup: too many distinctions for the eye to parse */
.label { font-weight: 300; }
.body { font-weight: 400; }
.subtitle { font-weight: 500; }
.title { font-weight: 600; }
.heading { font-weight: 700; }
.hero { font-weight: 800; }
```

CORRECT:

```css
/* Two weights: normal and bold. Size creates hierarchy, not weight. */
body { font-weight: 400; }
strong, th, h1, h2, h3 { font-weight: 600; }
```

## Font Loading Strategy

Prevent FOUT (flash of unstyled text) and FOIT (flash of invisible text) with proper loading.

INCORRECT:

```css
/* No fallback management: invisible text for 3+ seconds on slow connections */
@font-face {
  font-family: "Monaspace Neon";
  src: url("/fonts/MonaspaceNeon.woff2") format("woff2");
  /* font-display defaults to "auto" -- browser-dependent, often "block" */
}
```

CORRECT:

```css
/* Swap with metric-compatible fallback */
@font-face {
  font-family: "Monaspace Neon";
  src: url("/fonts/MonaspaceNeon.woff2") format("woff2");
  font-display: swap;
}

/* Metric-adjusted fallback to minimize layout shift */
@font-face {
  font-family: "Monaspace Neon Fallback";
  src: local("Courier New");
  size-adjust: 100%;
  ascent-override: 95%;
  descent-override: 25%;
}

body {
  font-family: "Monaspace Neon", "Monaspace Neon Fallback", ui-monospace, monospace;
}
```

## Heading Levels Match Document Structure

Heading level communicates document hierarchy to assistive technology. Never skip levels or choose headings by size.

INCORRECT:

```tsx
// Choosing heading level by visual size
<h1>Site Title</h1>
<h4>Section title</h4>  {/* Skipped h2, h3 */}
<h2>Subsection</h2>     {/* Larger heading under smaller one */}
```

CORRECT:

```tsx
// Heading levels follow document hierarchy; style independently
<h1>Site Title</h1>
<h2>Section Title</h2>
<h3>Subsection</h3>

{/* If you need h2-level content with h3-level styling: */}
<h2 className="text-lg">Visually Smaller Section</h2>
```
