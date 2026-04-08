---
title: Tailwind CSS Patterns
impact: HIGH
impactDescription: Tailwind misuse creates unreadable markup and inconsistent design
tags: tailwind, css, utility-first, responsive, dark-mode, config
---

# Tailwind CSS Patterns

## Design Token Mapping in Config

Tailwind config should mirror the design token hierarchy. Do not use default scales with scattered overrides.

INCORRECT:

```js
// Scattered overrides on top of defaults -- no system
module.exports = {
  theme: {
    extend: {
      colors: {
        'special-bg': '#1a1a2e',
        'my-accent': '#ff7edb',
        'text-main': '#e2e8f0',
        'card-bg-dark': '#1e293b',
      }
    }
  }
}
```

CORRECT:

```js
// DROO-flavored config: monospace default, systematic tokens
module.exports = {
  theme: {
    fontFamily: {
      mono: ['"Monaspace Neon"', '"Monaspace Argon"', '"Monaspace Krypton"', 'ui-monospace', 'monospace'],
      sans: ['"General Sans"', '"Satoshi"', '"Cabinet Grotesk"', 'ui-sans-serif', 'system-ui', 'sans-serif'],
    },
    colors: {
      transparent: 'transparent',
      current: 'currentColor',
      // Semantic tokens (use these in markup)
      surface: 'var(--color-bg-primary)',
      foreground: 'var(--color-text-primary)',
      muted: 'var(--color-text-muted)',
      accent: 'var(--color-accent)',
      border: 'var(--color-border)',
      // Functional tokens
      error: 'var(--color-error)',
      success: 'var(--color-success)',
      warning: 'var(--color-warning)',
    },
  }
}
```

## Extracting Components vs @apply

`@apply` is for base-layer patterns, not component extraction. Use React components for repeated UI patterns.

INCORRECT:

```css
/* @apply for everything: defeats utility-first, creates hidden dependencies */
.card {
  @apply rounded-lg shadow-md p-4 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700;
}
.card-title {
  @apply text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2;
}
.card-body {
  @apply text-sm text-gray-600 dark:text-gray-400;
}
```

Also INCORRECT:

```tsx
// 30+ classes on every element: unreadable, unmaintainable
<div className="rounded-lg shadow-md p-4 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 hover:shadow-lg transition-shadow duration-200 cursor-pointer max-w-sm mx-auto mt-4 mb-6">
  <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2 truncate">
    {title}
  </h3>
</div>
```

CORRECT:

```tsx
// React component extraction: readable, typed, composable
function Card({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={cn("border border-default bg-surface p-4", className)}>
      {children}
    </div>
  );
}

function CardTitle({ children }: { children: React.ReactNode }) {
  return <h3 className="text-lg font-semibold text-foreground mb-2 truncate">{children}</h3>;
}
```

```css
/* @apply is appropriate ONLY for base-layer resets */
@layer base {
  body {
    @apply bg-surface text-foreground font-mono antialiased;
  }
}
```

## Mobile-First Responsive Design

Base styles are mobile. Larger breakpoints add, never subtract.

INCORRECT:

```tsx
// Desktop-first: base is desktop, overriding down
<div className="flex flex-row gap-8 p-8 sm:flex-col sm:gap-4 sm:p-4">
  <aside className="w-64 sm:w-full sm:hidden">...</aside>
  <main className="flex-1">...</main>
</div>
```

CORRECT:

```tsx
// Mobile-first: base is mobile, enhancing up
<div className="flex flex-col gap-4 p-4 md:flex-row md:gap-8 md:p-8">
  <aside className="hidden md:block md:w-64">...</aside>
  <main className="flex-1">...</main>
</div>
```

## Dark Mode with Class Strategy

Use `class` or `selector` strategy for user-controlled theming. The `media` strategy gives no user control.

INCORRECT:

```js
// tailwind.config.js
module.exports = {
  darkMode: 'media', // no user toggle, follows OS only
}
```

CORRECT:

```js
// tailwind.config.js
module.exports = {
  darkMode: ['selector', '[data-theme="dark"]'],
}
```

```tsx
// Theme toggle sets the attribute on <html>
function toggleTheme() {
  const next = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
  document.documentElement.dataset.theme = next;
  localStorage.setItem("theme", next);
}
```

## Avoiding Arbitrary Values

Arbitrary values (`text-[13px]`, `p-[7px]`, `w-[273px]`) bypass the design system. Use them only for one-off values that genuinely cannot map to the scale.

INCORRECT:

```tsx
// Arbitrary values everywhere: no system
<div className="p-[13px] mt-[17px] w-[273px] text-[15px] gap-[11px]">
  <h2 className="text-[22px] mb-[9px]">Title</h2>
</div>
```

CORRECT:

```tsx
// Scale values: predictable, consistent
<div className="p-3 mt-4 w-64 text-base gap-3">
  <h2 className="text-xl mb-2">Title</h2>
</div>
```

## Monospace-First Typography

In a DROO-flavored system, `font-mono` is the default. Sans-serif is the override.

INCORRECT:

```tsx
// Sans-serif default with mono as exception
<body className="font-sans">
  <code className="font-mono">code here</code>
</body>
```

CORRECT:

```tsx
// Monospace default, sans only for long prose
<body className="font-mono">
  <article className="font-sans max-w-prose">
    {/* Long-form prose benefits from proportional type */}
    <p>Extended reading content goes here...</p>
  </article>
  <aside>
    {/* Data, status, navigation: monospace by default */}
    <StatusIndicator />
    <MetricsPanel />
  </aside>
</body>
```
