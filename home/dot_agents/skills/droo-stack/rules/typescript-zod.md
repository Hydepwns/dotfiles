---
title: TypeScript Runtime Validation with Zod
impact: HIGH
impactDescription: type-safe runtime validation, no runtime surprises
tags: typescript, zod, validation, schemas, runtime
---

# TypeScript Runtime Validation with Zod

## safeParse over parse

Use `safeParse` to handle validation errors explicitly. `parse` throws, which leads to uncaught exceptions or empty catch blocks.

### Incorrect -- parse with try/catch

```typescript
function handleWebhook(raw: unknown): WebhookEvent {
  try {
    return WebhookEventSchema.parse(raw);
  } catch {
    // Error swallowed -- caller has no idea what went wrong
    return { type: "unknown", payload: {} } as WebhookEvent;
  }
}
```

### Correct -- safeParse with explicit error handling

```typescript
function handleWebhook(raw: unknown): Result<WebhookEvent, ZodError> {
  const result = WebhookEventSchema.safeParse(raw);
  if (!result.success) {
    logger.warn("Invalid webhook payload", { errors: result.error.flatten() });
    return { ok: false, error: result.error };
  }
  return { ok: true, data: result.data };
}
```

---

## Discriminated unions with z.discriminatedUnion

Use `z.discriminatedUnion` when a payload has a literal discriminator field. Do not use `z.union` for this -- it tries each branch sequentially and produces poor error messages.

### Incorrect -- z.union for tagged payloads

```typescript
const EventSchema = z.union([
  z.object({ type: z.literal("click"), x: z.number(), y: z.number() }),
  z.object({ type: z.literal("keypress"), key: z.string(), code: z.number() }),
  z.object({ type: z.literal("scroll"), deltaY: z.number() }),
]);
// Error messages list failures from ALL branches -- confusing for callers
```

### Correct -- z.discriminatedUnion on the "type" field

```typescript
const EventSchema = z.discriminatedUnion("type", [
  z.object({ type: z.literal("click"), x: z.number(), y: z.number() }),
  z.object({ type: z.literal("keypress"), key: z.string(), code: z.number() }),
  z.object({ type: z.literal("scroll"), deltaY: z.number() }),
]);
// Error messages pinpoint the exact branch based on "type" value
```

---

## .transform() and .refine() for custom validation

Use `.refine()` for validation constraints that go beyond type shape. Use `.transform()` to coerce or normalize data during parsing. Keep transforms pure.

### Incorrect -- manual post-parse validation

```typescript
const RangeSchema = z.object({
  min: z.number(),
  max: z.number(),
});

function parseRange(input: unknown) {
  const range = RangeSchema.parse(input);
  if (range.min >= range.max) {
    throw new Error("min must be less than max");
  }
  return range;
}
```

### Correct -- refine baked into the schema

```typescript
const RangeSchema = z
  .object({
    min: z.number(),
    max: z.number(),
  })
  .refine((r) => r.min < r.max, {
    message: "min must be less than max",
    path: ["min"],
  });

// Transform example -- normalize email during parse
const UserInputSchema = z.object({
  email: z
    .string()
    .email()
    .transform((e) => e.toLowerCase().trim()),
  age: z
    .string()
    .transform((v) => parseInt(v, 10))
    .pipe(z.number().int().positive()),
});
```

---

## Inferring types from schemas with z.infer

Define the schema first, then derive the type. Do not maintain a separate interface that can drift from the schema.

### Incorrect -- separate interface and schema that drift apart

```typescript
interface User {
  id: string;
  name: string;
  email: string;
  role: "admin" | "member";
}

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(["admin", "member", "viewer"]), // "viewer" added here but not in interface
});
```

### Correct -- single source of truth

```typescript
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(["admin", "member", "viewer"]),
});

type User = z.infer<typeof UserSchema>;
// User type is always in sync with runtime validation
```

---

## Composing schemas with .extend(), .merge(), .pick(), .omit()

Build schemas incrementally. Do not duplicate field definitions across related schemas.

### Incorrect -- duplicated fields across schemas

```typescript
const CreateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(["admin", "member"]),
});

const UpdateUserSchema = z.object({
  name: z.string().min(1).optional(),
  email: z.string().email().optional(),
  role: z.enum(["admin", "member"]).optional(), // duplicated enum, will drift
});

const UserResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),           // duplicated
  email: z.string().email(),          // duplicated
  role: z.enum(["admin", "member"]),  // duplicated
  createdAt: z.string().datetime(),
});
```

### Correct -- compose from a base schema

```typescript
const UserBaseSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(["admin", "member"]),
});

const CreateUserSchema = UserBaseSchema;

const UpdateUserSchema = UserBaseSchema.partial();

const UserResponseSchema = UserBaseSchema.extend({
  id: z.string().uuid(),
  createdAt: z.string().datetime(),
});

type CreateUser = z.infer<typeof CreateUserSchema>;
type UpdateUser = z.infer<typeof UpdateUserSchema>;
type UserResponse = z.infer<typeof UserResponseSchema>;
```
