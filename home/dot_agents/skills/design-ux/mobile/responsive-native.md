---
title: Mobile and Responsive Design
impact: MEDIUM
impactDescription: Mobile-specific concerns beyond responsive web
tags: mobile, responsive, touch, viewport, native, safe-area, performance
---

# Mobile and Responsive Design

## Touch Target Sizing

Interactive elements must be large enough for reliable finger taps. Spacing between targets prevents mis-taps.

INCORRECT:

```tsx
// Tiny tap targets: 24x24px icons with no spacing
<div className="flex gap-1">
  <button className="w-6 h-6"><IconEdit /></button>
  <button className="w-6 h-6"><IconDelete /></button>
  <button className="w-6 h-6"><IconShare /></button>
</div>
```

CORRECT:

```tsx
// 44x44px minimum (iOS HIG), 48x48dp (Material), with adequate spacing
<div className="flex gap-2">
  <button className="w-11 h-11 flex items-center justify-center">
    <IconEdit className="w-5 h-5" />
  </button>
  <button className="w-11 h-11 flex items-center justify-center">
    <IconDelete className="w-5 h-5" />
  </button>
  <button className="w-11 h-11 flex items-center justify-center">
    <IconShare className="w-5 h-5" />
  </button>
</div>
```

The icon can be visually small (20x20px) inside a larger tap target (44x44px).

## Viewport and Safe Areas

Account for notches, home indicators, and system bars. Content must not hide behind hardware features.

INCORRECT:

```html
<!-- Content hidden behind notch and home indicator -->
<meta name="viewport" content="width=device-width, initial-scale=1">
<body style="padding: 0;">
  <header>Title</header>
  <footer>Navigation</footer>
</body>
```

CORRECT:

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
```

```css
/* Safe area insets for notched devices */
header {
  padding-top: env(safe-area-inset-top);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

footer {
  padding-bottom: env(safe-area-inset-bottom);
}

/* Or use logical properties for the whole app */
.app {
  padding:
    env(safe-area-inset-top)
    env(safe-area-inset-right)
    env(safe-area-inset-bottom)
    env(safe-area-inset-left);
}
```

## Mobile-First Progressive Enhancement

Base styles are mobile. Larger breakpoints enhance, never subtract.

INCORRECT:

```tsx
// Desktop-first: hiding things on mobile
<nav className="flex items-center gap-4">
  <Logo />
  <NavLinks className="sm:hidden" />           {/* hidden on mobile */}
  <SearchBar className="sm:hidden" />           {/* hidden on mobile */}
  <HamburgerMenu className="hidden sm:block" /> {/* shown only on mobile */}
</nav>
```

CORRECT:

```tsx
// Mobile-first: mobile is the base, desktop adds
<nav className="flex items-center justify-between">
  <Logo />
  <HamburgerMenu className="md:hidden" />         {/* mobile: hamburger */}
  <div className="hidden md:flex md:items-center md:gap-4">
    <NavLinks />                                    {/* desktop: full nav */}
    <SearchBar />
  </div>
</nav>
```

## Responsive Images

Serve appropriately sized images. Do not send desktop-resolution images to mobile devices.

INCORRECT:

```tsx
// Same 2400px image for all devices
<img src="/hero-2400w.jpg" alt="Hero" className="w-full" />
```

CORRECT:

```tsx
// Responsive srcset: browser picks the right size
<img
  src="/hero-800w.jpg"
  srcSet="/hero-400w.jpg 400w, /hero-800w.jpg 800w, /hero-1200w.jpg 1200w, /hero-2400w.jpg 2400w"
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 80vw, 1200px"
  alt="Hero"
  className="w-full aspect-video object-cover"
  loading="lazy"
  decoding="async"
/>
```

## Performance as UX

On mobile, performance is a design decision. Slow is broken.

INCORRECT:

```tsx
// Client-side rendering of static content: blank screen on slow 3G
function HomePage() {
  const [data, setData] = useState(null);
  useEffect(() => {
    fetch("/api/homepage").then(r => r.json()).then(setData);
  }, []);

  if (!data) return null;  // blank screen while loading
  return <PageContent data={data} />;
}
```

CORRECT:

```tsx
// Server-rendered with streaming, skeleton for dynamic parts
function HomePage({ staticContent }: { staticContent: StaticData }) {
  return (
    <>
      {/* Static content: rendered server-side, visible immediately */}
      <Hero content={staticContent.hero} />
      <Features items={staticContent.features} />

      {/* Dynamic content: suspense boundary with skeleton */}
      <Suspense fallback={<FeedSkeleton />}>
        <DynamicFeed />
      </Suspense>
    </>
  );
}
```

## Scroll Behavior

Respect mobile scroll conventions. Avoid scroll hijacking.

INCORRECT:

```css
/* Scroll hijacking: takes over native scroll behavior */
html { overflow: hidden; }
.container {
  height: 100vh;
  overflow-y: scroll;
  scroll-snap-type: y mandatory;
}
.section {
  height: 100vh;
  scroll-snap-align: start;
}
```

CORRECT:

```css
/* Native scroll with smooth behavior when supported */
html {
  scroll-behavior: smooth;
}

/* Fixed elements use position: sticky, not scroll hijacking */
.sticky-header {
  position: sticky;
  top: 0;
  z-index: 10;
}

@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
}
```

## Input Modes

Set appropriate input modes for form fields to trigger the right mobile keyboard.

INCORRECT:

```tsx
// Generic text input for everything
<input type="text" placeholder="Phone number" />
<input type="text" placeholder="Email" />
<input type="text" placeholder="Amount" />
```

CORRECT:

```tsx
// Input modes trigger the right keyboard
<input type="tel" inputMode="tel" placeholder="Phone number" autoComplete="tel" />
<input type="email" inputMode="email" placeholder="Email" autoComplete="email" />
<input type="text" inputMode="decimal" placeholder="Amount" />
<input type="text" inputMode="numeric" pattern="[0-9]*" placeholder="PIN" />
<input type="url" inputMode="url" placeholder="Website" autoComplete="url" />
```
