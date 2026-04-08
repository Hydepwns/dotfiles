---
title: React Component Design
impact: HIGH
impactDescription: Component architecture determines reusability and maintainability
tags: react, components, composition, props, patterns, compound
---

# React Component Design

## Composition Over Configuration

Small, composable components beat mega-components with boolean props. When a component has more than 3-4 configuration props, it needs to be split.

INCORRECT:

```tsx
// Mega-component: 12 boolean props, impossible to reason about interactions
<DataTable
  columns={columns}
  data={data}
  sortable
  filterable
  paginated
  searchable
  exportable
  selectable
  stickyHeader
  striped
  bordered
  compact
  pageSize={20}
  onSelect={handleSelect}
/>
```

CORRECT:

```tsx
// Compound component: each concern is explicit and composable
<DataTable data={data}>
  <DataTable.Toolbar>
    <DataTable.Search />
    <DataTable.Export />
  </DataTable.Toolbar>
  <DataTable.Header sticky>
    {columns.map((col) => (
      <DataTable.Column key={col.key} sortable={col.sortable}>
        {col.label}
      </DataTable.Column>
    ))}
  </DataTable.Header>
  <DataTable.Body striped />
  <DataTable.Selection onSelect={handleSelect} />
  <DataTable.Pagination pageSize={20} />
</DataTable>
```

## Consistent Prop Interfaces

Establish a shared prop vocabulary across all components. Do not invent new names for the same concept.

INCORRECT:

```tsx
// Every component invents its own naming
<Button onPress={handleClick} small primary />
<Input onValueChange={handleChange} compact theme="main" />
<Card onClick={handleCardClick} size="sm" variant="highlighted" />
<Modal onDismiss={handleClose} isCompact isPrimary />
```

CORRECT:

```tsx
// Shared vocabulary: size, variant, on{Event}
<Button onClick={handleClick} size="sm" variant="primary" />
<Input onChange={handleChange} size="sm" variant="default" />
<Card onClick={handleCardClick} size="sm" variant="accent" />
<Modal onClose={handleClose} size="sm" variant="primary" />
```

Standard prop vocabulary:
- **size**: `"sm" | "md" | "lg"` (not `small`, `compact`, `tiny`)
- **variant**: `"default" | "primary" | "accent" | "destructive" | "ghost"`
- **Events**: `on{Event}` (not `handle{Event}`, `onPress`, `onDismiss`)
- **Boolean states**: `disabled`, `loading`, `open` (not `isDisabled`, `isLoading`)

## Separation of Layout and Content

Components own their internal layout. They never own their external position (margins, grid placement).

INCORRECT:

```tsx
// Component owns its own margins -- breaks in different layouts
function Card({ children }: { children: React.ReactNode }) {
  return (
    <div className="p-4 mb-6 ml-4 w-1/3 border border-default">
      {children}
    </div>
  );
}
```

CORRECT:

```tsx
// Component owns only its internals
function Card({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={cn("p-4 border border-default", className)}>
      {children}
    </div>
  );
}

// Parent controls layout
<div className="grid grid-cols-3 gap-6">
  <Card>First</Card>
  <Card>Second</Card>
  <Card>Third</Card>
</div>
```

## Render Slots for Flexibility

When a component needs customizable sections, use children or named slots -- not conditional rendering flags.

INCORRECT:

```tsx
// Configuration via flags: rigid, hard to customize
<PageHeader
  showBreadcrumbs
  showSearch
  showUserMenu
  showNotifications
  breadcrumbItems={items}
  searchPlaceholder="Search..."
  userName={user.name}
  notificationCount={3}
/>
```

CORRECT:

```tsx
// Named slots via children: flexible, no prop explosion
<PageHeader>
  <PageHeader.Left>
    <Breadcrumbs items={items} />
  </PageHeader.Left>
  <PageHeader.Center>
    <SearchInput placeholder="Search..." />
  </PageHeader.Center>
  <PageHeader.Right>
    <NotificationBell count={3} />
    <UserMenu name={user.name} />
  </PageHeader.Right>
</PageHeader>
```

## Error and Loading Boundaries

Handle error and loading states at boundary level, not in every component.

INCORRECT:

```tsx
// Every component handles its own loading/error state
function UserList() {
  const { data, isLoading, error } = useUsers();
  if (isLoading) return <div className="animate-pulse h-32 bg-gray-200" />;
  if (error) return <div className="text-red-500">Failed to load users</div>;
  return <ul>{data.map((u) => <li key={u.id}>{u.name}</li>)}</ul>;
}

function ProjectList() {
  const { data, isLoading, error } = useProjects();
  if (isLoading) return <div className="animate-pulse h-32 bg-gray-200" />;
  if (error) return <div className="text-red-500">Failed to load projects</div>;
  return <ul>{data.map((p) => <li key={p.id}>{p.name}</li>)}</ul>;
}
```

CORRECT:

```tsx
// Shared boundary components
<ErrorBoundary fallback={<ErrorFallback />}>
  <Suspense fallback={<Skeleton className="h-32" />}>
    <UserList />
  </Suspense>
  <Suspense fallback={<Skeleton className="h-32" />}>
    <ProjectList />
  </Suspense>
</ErrorBoundary>

// Components only handle the happy path
function UserList() {
  const users = useUsers(); // throws on error, suspends on loading
  return <ul>{users.map((u) => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

## Forwarding Refs and HTML Props

Interactive components should forward refs and accept standard HTML attributes.

INCORRECT:

```tsx
// Closed component: no ref, no HTML attributes passthrough
function Button({ label, onClick }: { label: string; onClick: () => void }) {
  return <button onClick={onClick}>{label}</button>;
}

// Cannot: <Button ref={ref} aria-label="..." data-testid="..." />
```

CORRECT:

```tsx
// Open component: forwards ref, spreads HTML attributes
const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ children, variant = "default", size = "md", className, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(buttonVariants({ variant, size }), className)}
        {...props}
      >
        {children}
      </button>
    );
  }
);
```
