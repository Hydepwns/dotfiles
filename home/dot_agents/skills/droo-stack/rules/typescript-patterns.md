---
title: TypeScript Functional Patterns
impact: HIGH
impactDescription: safer code, fewer bugs, easier to reason about
tags: typescript, functional, immutability, error-handling, strict
---

# TypeScript Functional Patterns

## map/filter/reduce over imperative loops

Use array methods for data transformations. They compose, they are declarative, and they avoid off-by-one errors and mutation.

### Incorrect -- imperative loop with mutation

```typescript
function getActiveEmails(users: User[]): string[] {
  const emails: string[] = [];
  for (let i = 0; i < users.length; i++) {
    if (users[i].active) {
      emails.push(users[i].email.toLowerCase());
    }
  }
  return emails;
}
```

### Correct -- functional pipeline

```typescript
function getActiveEmails(users: readonly User[]): string[] {
  return users.filter((user) => user.active).map((user) => user.email.toLowerCase());
}
```

---

## Immutable updates

Never mutate function arguments. Use spread syntax for shallow updates, `structuredClone` for deep copies, and `Readonly<T>` / `as const` to enforce immutability at the type level.

### Incorrect -- mutating the input object

```typescript
function applyDiscount(order: Order, pct: number): Order {
  order.items.forEach((item) => {
    item.price = item.price * (1 - pct / 100);
  });
  order.discountApplied = true;
  return order;
}
```

### Correct -- immutable update returning a new object

```typescript
function applyDiscount(order: Readonly<Order>, pct: number): Order {
  return {
    ...order,
    discountApplied: true,
    items: order.items.map((item) => ({
      ...item,
      price: item.price * (1 - pct / 100),
    })),
  };
}
```

---

## Never swallow errors

Every catch block must log, rethrow, or return a typed error. An empty catch is a silent data-loss bug waiting to happen.

### Incorrect -- empty catch, generic catch, catch that lies

```typescript
// Silent swallow -- caller thinks everything is fine
async function fetchUser(id: string): Promise<User | null> {
  try {
    const res = await api.get(`/users/${id}`);
    return res.data;
  } catch {
    return null;
  }
}

// Generic rethrow that loses context
async function saveOrder(order: Order): Promise<void> {
  try {
    await db.orders.insert(order);
  } catch (e) {
    throw new Error("something went wrong");
  }
}
```

### Correct -- log with context, rethrow with cause, or return typed error

```typescript
async function fetchUser(id: string): Promise<Result<User, FetchError>> {
  try {
    const res = await api.get(`/users/${id}`);
    return { ok: true, data: res.data };
  } catch (error) {
    logger.error("Failed to fetch user", { id, error });
    return { ok: false, error: { kind: "fetch_failed", cause: error, id } };
  }
}

async function saveOrder(order: Order): Promise<void> {
  try {
    await db.orders.insert(order);
  } catch (cause) {
    throw new Error(`Failed to save order ${order.id}`, { cause });
  }
}
```

---

## Discriminated unions over type assertions

Model variant data with a literal discriminator field. Avoid `as` casts -- they bypass the type checker and crash at runtime when assumptions break.

### Incorrect -- type assertions to force a type

```typescript
type ApiResponse = {
  data?: UserData;
  error?: string;
  code?: number;
};

function handleResponse(res: ApiResponse): UserData {
  if (res.error) {
    throw new Error(res.error);
  }
  return res.data as UserData; // crashes if data is undefined
}
```

### Correct -- discriminated union, exhaustive handling

```typescript
type ApiResponse =
  | { status: "success"; data: UserData }
  | { status: "error"; error: string; code: number };

function handleResponse(res: ApiResponse): UserData {
  switch (res.status) {
    case "success":
      return res.data; // type-narrowed, no assertion needed
    case "error":
      throw new ApiError(res.error, res.code);
    default:
      // Exhaustiveness check -- compiler error if a variant is unhandled
      const _exhaustive: never = res;
      throw new Error(`Unhandled status: ${JSON.stringify(_exhaustive)}`);
  }
}
```

---

## Pure functions where possible

Functions that depend only on their arguments and produce no side effects are easier to test, compose, and reason about. Isolate side effects at the edges.

### Incorrect -- hidden dependencies and side effects

```typescript
let taxRate = 0.08;

function calculateTotal(items: CartItem[]): number {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  const total = subtotal * (1 + taxRate);
  analytics.track("cart_total_calculated", { total }); // side effect
  return total;
}
```

### Correct -- pure calculation, side effects at the call site

```typescript
function calculateTotal(items: readonly CartItem[], taxRate: number): number {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  return subtotal * (1 + taxRate);
}

// Side effects live at the boundary
const total = calculateTotal(cart.items, config.taxRate);
analytics.track("cart_total_calculated", { total });
```
