---
title: Accessibility
impact: CRITICAL
impactDescription: Accessibility failures exclude users and create legal liability
tags: accessibility, wcag, a11y, keyboard, aria, contrast, semantic-html
---

# Accessibility

## Semantic HTML Over Div Soup

Native HTML elements provide keyboard support, screen reader announcements, and focus management for free. Use them.

INCORRECT:

```html
<div class="nav">
  <div class="nav-item" onclick="navigate('/')">Home</div>
  <div class="nav-item" onclick="navigate('/about')">About</div>
</div>
<div class="main-content">
  <div class="heading">Page Title</div>
  <div class="paragraph">Some text content here.</div>
</div>
```

CORRECT:

```html
<nav aria-label="Main">
  <a href="/">Home</a>
  <a href="/about">About</a>
</nav>
<main>
  <h1>Page Title</h1>
  <p>Some text content here.</p>
</main>
```

## Interactive Elements

Never reimplement what native elements provide.

INCORRECT:

```tsx
// Reimplementing a button from scratch
<div
  role="button"
  tabIndex={0}
  aria-label="Submit form"
  onClick={handleSubmit}
  onKeyDown={(e) => {
    if (e.key === "Enter" || e.key === " ") handleSubmit();
  }}
  className="cursor-pointer select-none"
>
  Submit
</div>
```

CORRECT:

```tsx
// Native button: keyboard, focus, click, form submission -- all free
<button type="submit" onClick={handleSubmit}>
  Submit
</button>
```

## Color Contrast Ratios

WCAG AA minimum: 4.5:1 for normal text, 3:1 for large text (18px+ or 14px+ bold).

INCORRECT:

```css
/* Light gray on white: 2.85:1 ratio -- fails WCAG AA */
.muted-text { color: #999; background: #fff; }

/* Low contrast accent: 2.1:1 ratio */
.link { color: #6366f1; background: #e0e7ff; }
```

CORRECT:

```css
/* Meets 4.5:1 for normal text */
.muted-text { color: #6b7280; background: #fff; }    /* 5.0:1 */

/* DROO palette: high contrast by default */
.text-primary { color: #e2e8f0; background: #1a1a2e; }  /* 11.3:1 */
.text-muted { color: #94a3b8; background: #1a1a2e; }    /* 6.4:1 */
```

## Keyboard Navigation

Every interactive element must be reachable and operable via keyboard alone.

INCORRECT:

```tsx
// Custom dropdown with no keyboard support
<div className="dropdown" onClick={() => setOpen(!open)}>
  <span>{selected}</span>
  {open && (
    <div className="dropdown-menu">
      {options.map((opt) => (
        <div key={opt} onClick={() => select(opt)}>{opt}</div>
      ))}
    </div>
  )}
</div>
```

CORRECT:

```tsx
// Keyboard-accessible with proper ARIA
<div className="dropdown">
  <button
    aria-expanded={open}
    aria-haspopup="listbox"
    onClick={() => setOpen(!open)}
    onKeyDown={(e) => {
      if (e.key === "Escape") setOpen(false);
      if (e.key === "ArrowDown") { setOpen(true); focusFirst(); }
    }}
  >
    {selected}
  </button>
  {open && (
    <ul role="listbox" aria-label="Options">
      {options.map((opt, i) => (
        <li
          key={opt}
          role="option"
          tabIndex={0}
          aria-selected={opt === selected}
          onClick={() => select(opt)}
          onKeyDown={(e) => {
            if (e.key === "Enter") select(opt);
            if (e.key === "Escape") setOpen(false);
            if (e.key === "ArrowDown") focusNext(i);
            if (e.key === "ArrowUp") focusPrev(i);
          }}
        >
          {opt}
        </li>
      ))}
    </ul>
  )}
</div>
```

Better yet: use a headless UI library (Radix, Headless UI, React Aria) that handles this correctly.

## ARIA as Last Resort

ARIA supplements what HTML cannot express. It does not replace semantic elements.

INCORRECT:

```tsx
// ARIA replacing what HTML provides natively
<div role="navigation" aria-label="Main">
  <div role="link" tabIndex={0} aria-label="Home" onClick={() => navigate("/")}>
    Home
  </div>
</div>
<div role="heading" aria-level={1}>Page Title</div>
```

CORRECT:

```tsx
// HTML first, ARIA only for what HTML cannot express
<nav aria-label="Main">
  <a href="/">Home</a>
</nav>
<h1>Page Title</h1>

{/* ARIA is appropriate here: live region for dynamic content */}
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>
```

## Motion and Reduced Motion

Respect user preferences for reduced motion. Animations must have a purpose (communicating state change, guiding attention).

INCORRECT:

```css
/* Animation with no reduced-motion fallback */
.card {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.card:hover {
  transform: translateY(-4px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0,0,0,0.3);
}
```

CORRECT:

```css
/* Functional transition with reduced-motion respect */
.card {
  transition: border-color 0.15s ease;
}
.card:hover {
  border-color: var(--color-accent);
}

@media (prefers-reduced-motion: reduce) {
  .card { transition: none; }
}
```

## Focus Indicators

Never remove focus indicators without providing an alternative.

INCORRECT:

```css
/* Removing focus for "cleaner" look */
*:focus { outline: none; }
button:focus { outline: none; }
```

CORRECT:

```css
/* Custom focus indicator that is visible and clear */
:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
}

/* Only suppress default for mouse users, keep for keyboard */
:focus:not(:focus-visible) {
  outline: none;
}
```
