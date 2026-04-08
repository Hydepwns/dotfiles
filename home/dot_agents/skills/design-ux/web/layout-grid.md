---
title: Layout and Grid Systems
impact: HIGH
impactDescription: Layout determines information hierarchy and scanning patterns
tags: layout, grid, flexbox, spacing, responsive, breakpoints, container
---

# Layout and Grid Systems

## CSS Grid for Page Layout, Flexbox for Component Layout

Grid is for 2D page structure. Flexbox is for single-axis alignment within components. Do not nest flexbox for 2D layouts.

INCORRECT:

```css
/* Flexbox for 2D page layout: awkward, fragile */
.page {
  display: flex;
  flex-wrap: wrap;
}
.sidebar { flex: 0 0 250px; }
.main { flex: 1; display: flex; flex-direction: column; }
.footer { flex: 0 0 100%; }
```

CORRECT:

```css
/* Grid for page layout */
.page {
  display: grid;
  grid-template-columns: 250px 1fr;
  grid-template-rows: auto 1fr auto;
  grid-template-areas:
    "sidebar header"
    "sidebar main"
    "sidebar footer";
  min-height: 100dvh;
}

/* Flexbox for component-level alignment */
.toolbar {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}
```

## Spacing Rhythm

All gaps use spacing tokens from the design token system. Never mix arbitrary values.

INCORRECT:

```tsx
// Inconsistent gaps: no rhythm
<div className="space-y-3">
  <Header className="mb-5" />
  <div className="grid gap-7">
    <Card className="p-[13px]" />
    <Card className="p-4" />
  </div>
  <Footer className="mt-9" />
</div>
```

CORRECT:

```tsx
// Consistent rhythm from the spacing scale
<div className="space-y-6">
  <Header />
  <div className="grid gap-4">
    <Card />
    <Card />
  </div>
  <Footer />
</div>
```

## Container Width Constraints

Text content must be constrained. Lines longer than ~75 characters are unreadable.

INCORRECT:

```tsx
// Full-width text: 120+ characters per line on desktop
<div className="w-full px-4">
  <h1>{title}</h1>
  <p>{longDescription}</p>
</div>
```

CORRECT:

```tsx
// Constrained prose, wider for data-dense content
<div className="mx-auto px-4">
  {/* Text: max-w-prose (~65ch) */}
  <article className="max-w-prose">
    <h1>{title}</h1>
    <p>{longDescription}</p>
  </article>

  {/* Data tables: wider, but still bounded */}
  <div className="max-w-6xl">
    <DataTable data={data} />
  </div>
</div>
```

## Intrinsic Sizing

Prefer `min-content`, `max-content`, `fit-content`, and `minmax()` over fixed pixel widths. Let content inform the grid.

INCORRECT:

```css
/* Fixed widths that break on content changes */
.sidebar { width: 250px; }
.label-col { width: 120px; }
.action-col { width: 80px; }
```

CORRECT:

```css
/* Intrinsic sizing: adapts to content */
.layout {
  display: grid;
  grid-template-columns: fit-content(300px) 1fr;
}

.data-grid {
  display: grid;
  grid-template-columns: max-content 1fr max-content;
}
```

```tsx
// Tailwind equivalents
<div className="grid grid-cols-[fit-content(300px)_1fr]">
  <Sidebar />
  <Main />
</div>
```

## Responsive Breakpoints

Use container queries where possible. When using media queries, use the standard breakpoints -- do not invent custom ones without justification.

INCORRECT:

```css
/* Custom breakpoints with no justification */
@media (min-width: 743px) { ... }
@media (min-width: 1087px) { ... }
@media (min-width: 1441px) { ... }
```

CORRECT:

```css
/* Standard breakpoints (Tailwind defaults: 640, 768, 1024, 1280, 1536) */
@media (min-width: 768px) { ... }  /* md: tablet */
@media (min-width: 1024px) { ... } /* lg: desktop */

/* Better: container queries for component-level responsiveness */
@container (min-width: 400px) {
  .card { grid-template-columns: auto 1fr; }
}
```

```tsx
// Tailwind container queries
<div className="@container">
  <div className="flex flex-col @md:flex-row @md:gap-4">
    <Thumbnail />
    <Details />
  </div>
</div>
```

## Avoiding Scroll Jank

Set explicit dimensions on elements that load async content. Use `aspect-ratio` for media.

INCORRECT:

```tsx
// Image with no dimensions: causes layout shift on load
<img src={url} alt={alt} />

// List that grows as items load
<div>
  {items.map((item) => <ListItem key={item.id} item={item} />)}
</div>
```

CORRECT:

```tsx
// Explicit aspect ratio: reserves space before load
<img src={url} alt={alt} className="aspect-video w-full object-cover" />

// Fixed-height container with overflow scroll
<div className="h-96 overflow-y-auto">
  {items.map((item) => <ListItem key={item.id} item={item} />)}
</div>
```
