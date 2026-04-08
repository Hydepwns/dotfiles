---
title: Design Principles
impact: CRITICAL
impactDescription: Foundation for all design decisions; wrong principles cascade into wrong everything
tags: design, principles, constraints, monospace, droo
---

# Design Principles

## Constraint-Based Design Over Decoration

Every visual element must serve information hierarchy. Start from a monospace grid and add only what communicates meaning.

INCORRECT:

```tsx
// Decoration-first: visual flair that adds no information
<div className="rounded-xl shadow-2xl bg-gradient-to-r from-purple-500 to-pink-500 p-8">
  <h2 className="text-3xl font-extrabold text-white drop-shadow-lg">
    Welcome Back
  </h2>
</div>
```

CORRECT:

```tsx
// Constraint-first: every element earns its place
<div className="border border-neutral-700 bg-neutral-900 p-4 font-mono">
  <h2 className="text-lg text-foreground">
    Welcome Back
  </h2>
</div>
```

## Content-First Hierarchy

Content determines structure. Navigation, headers, and controls derive from content needs, not the other way around.

INCORRECT:

```tsx
// Chrome-first: designing the shell, then filling with content
<AppShell>
  <Sidebar width={280}>
    <Logo />
    <NavSection title="Main" />
    <NavSection title="Settings" />
    <NavSection title="Help" />
  </Sidebar>
  <Header height={64}>
    <Breadcrumbs />
    <SearchBar />
    <UserMenu />
  </Header>
  <Content>
    {/* "now what goes here?" */}
  </Content>
</AppShell>
```

CORRECT:

```tsx
// Content-first: structure emerges from what users need to see and do
<main className="max-w-prose mx-auto p-4 font-mono">
  <h1 className="text-lg mb-4">Deployments</h1>
  <DeploymentList items={deployments} />
  <DeploymentDetail deployment={selected} />
</main>
// Navigation added only when content requires it
```

## Zero Layout Shift

No element should cause reflow on load, hover, or state change. Reserve space, use fixed containers, avoid content that pushes other content around.

INCORRECT:

```tsx
// Skeleton that changes height when content loads
{isLoading ? (
  <div className="h-8 bg-gray-200 animate-pulse rounded" />
) : (
  <div className="py-4">
    <h3>{title}</h3>
    <p>{description}</p>
  </div>
)}
```

CORRECT:

```tsx
// Fixed container preserves layout regardless of state
<div className="h-24 overflow-hidden">
  {isLoading ? (
    <div className="h-full bg-neutral-800 animate-pulse" />
  ) : (
    <>
      <h3 className="truncate">{title}</h3>
      <p className="line-clamp-2">{description}</p>
    </>
  )}
</div>
```

## Predictable Spacing

All spacing derives from a harmonic scale. No arbitrary values.

INCORRECT:

```css
/* Arbitrary spacing -- no rhythm, no system */
.card { padding: 13px; margin-bottom: 17px; }
.header { padding: 9px 22px; gap: 11px; }
.sidebar { width: 273px; padding: 15px; }
```

CORRECT:

```css
/* Harmonic scale: 4px base (4, 8, 12, 16, 24, 32, 48, 64) */
.card { padding: var(--space-4); margin-bottom: var(--space-5); }     /* 16px, 24px */
.header { padding: var(--space-2) var(--space-5); gap: var(--space-3); } /* 8px 24px, 12px */
.sidebar { width: 16rem; padding: var(--space-4); }                   /* 256px, 16px */
```

In terminal contexts: 1ch width, 1.5rem line-height. All dimensions are integer multiples.

## Design for the Worst Case

Design for truncation, missing data, error states, loading states, and empty states. Never design only for ideal data.

INCORRECT:

```tsx
// Only handles the happy path
<UserCard>
  <Avatar src={user.avatar} />
  <h3>{user.name}</h3>
  <p>{user.bio}</p>
</UserCard>
```

CORRECT:

```tsx
// Handles missing data, long names, no avatar, empty bio
<UserCard>
  <Avatar
    src={user.avatar}
    fallback={user.name?.[0] ?? "?"}
  />
  <h3 className="truncate">{user.name ?? "Unknown"}</h3>
  {user.bio ? (
    <p className="line-clamp-2">{user.bio}</p>
  ) : (
    <p className="text-muted italic">No bio</p>
  )}
</UserCard>
```

## Progressive Disclosure

Show summary first, detail on demand. Do not overwhelm with all data at once.

INCORRECT:

```tsx
// Everything visible at once -- user has to scan all of it
<SettingsPage>
  <GeneralSettings />      {/* 12 fields */}
  <NotificationSettings />  {/* 8 fields */}
  <SecuritySettings />      {/* 6 fields */}
  <BillingSettings />       {/* 10 fields */}
  <APISettings />           {/* 14 fields */}
</SettingsPage>
```

CORRECT:

```tsx
// Summary view with drill-down
<SettingsPage>
  <SettingGroup
    title="General"
    summary="English, UTC-5, dark mode"
    href="/settings/general"
  />
  <SettingGroup
    title="Notifications"
    summary="Email only, weekly digest"
    href="/settings/notifications"
  />
  {/* Each group expands to full form on navigation */}
</SettingsPage>
```
