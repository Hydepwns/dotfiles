---
title: Go Error Handling
impact: CRITICAL
impactDescription: proper error chains, debuggable failures
tags: go, errors, wrapping, sentinel, is, as
---

# Go Error Handling

## Always wrap errors with context

Bare `return err` loses call-site information. Wrap with `fmt.Errorf` so the
error chain tells you *where* and *why* things failed.

INCORRECT:

```go
func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, err // caller sees "open /etc/app.toml: no such file"
    }
    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, err // caller sees "invalid character '}'"
    }
    return &cfg, nil
}
```

CORRECT:

```go
func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("load config %s: %w", path, err)
    }
    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("parse config %s: %w", path, err)
    }
    return &cfg, nil
}
```

## Use %w to preserve the error chain, %v to break it

`%w` wraps the error so callers can unwrap it with `errors.Is`/`errors.As`.
Use `%v` only when you intentionally want to hide the underlying error from
callers (e.g., sanitizing internal details at an API boundary).

INCORRECT:

```go
// Breaks the chain -- callers cannot check for os.ErrNotExist
func OpenDB(path string) (*DB, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, fmt.Errorf("open db: %v", err)
    }
    return newDB(f), nil
}

// Caller check silently fails because chain is broken
if errors.Is(err, os.ErrNotExist) { // always false
    createDB()
}
```

CORRECT:

```go
// Preserves the chain -- callers can match os.ErrNotExist
func OpenDB(path string) (*DB, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, fmt.Errorf("open db: %w", err)
    }
    return newDB(f), nil
}

// Works because %w preserved the underlying error
if errors.Is(err, os.ErrNotExist) {
    createDB()
}
```

## Use errors.Is, never == for error comparison

Wrapped errors fail `==` comparison. `errors.Is` walks the full error chain.

INCORRECT:

```go
var ErrNotFound = errors.New("not found")

func GetUser(id string) (*User, error) {
    u, err := store.Lookup(id)
    if err != nil {
        return nil, fmt.Errorf("get user %s: %w", id, err)
    }
    return u, nil
}

// Breaks when err is wrapped
if err == ErrNotFound {
    http.Error(w, "user not found", 404)
}
```

CORRECT:

```go
var ErrNotFound = errors.New("not found")

func GetUser(id string) (*User, error) {
    u, err := store.Lookup(id)
    if err != nil {
        return nil, fmt.Errorf("get user %s: %w", id, err)
    }
    return u, nil
}

// Walks the chain -- works with any level of wrapping
if errors.Is(err, ErrNotFound) {
    http.Error(w, "user not found", 404)
}
```

## Sentinel errors vs custom error types

Use sentinel errors (`var Err... = errors.New(...)`) for simple conditions.
Use custom types when callers need structured data from the error.

INCORRECT:

```go
// Encoding structured info into a string that callers must parse
func Validate(req *Request) error {
    if req.Age < 0 {
        return fmt.Errorf("validation failed: field=age, reason=negative")
    }
    return nil
}

// Caller resorts to string matching
if strings.Contains(err.Error(), "field=age") {
    highlightField("age")
}
```

CORRECT:

```go
// Sentinel for simple conditions
var ErrEmptyName = errors.New("name must not be empty")

// Custom type when callers need structured data
type ValidationError struct {
    Field   string
    Reason  string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation: %s %s", e.Field, e.Reason)
}

func Validate(req *Request) error {
    if req.Age < 0 {
        return &ValidationError{Field: "age", Reason: "must not be negative"}
    }
    if req.Name == "" {
        return ErrEmptyName
    }
    return nil
}

// Caller uses errors.As to extract structured data
var ve *ValidationError
if errors.As(err, &ve) {
    highlightField(ve.Field)
}
```

## Return early on error (guard pattern)

Don't nest the happy path inside `if err == nil`. Check errors first, return
early, keep the main logic at the lowest indentation level.

INCORRECT:

```go
func ProcessOrder(id string) (*Receipt, error) {
    order, err := fetchOrder(id)
    if err == nil {
        validated, err := validateOrder(order)
        if err == nil {
            receipt, err := chargeCard(validated)
            if err == nil {
                return receipt, nil
            } else {
                return nil, fmt.Errorf("charge: %w", err)
            }
        } else {
            return nil, fmt.Errorf("validate: %w", err)
        }
    } else {
        return nil, fmt.Errorf("fetch: %w", err)
    }
}
```

CORRECT:

```go
func ProcessOrder(id string) (*Receipt, error) {
    order, err := fetchOrder(id)
    if err != nil {
        return nil, fmt.Errorf("fetch order %s: %w", id, err)
    }

    validated, err := validateOrder(order)
    if err != nil {
        return nil, fmt.Errorf("validate order %s: %w", id, err)
    }

    receipt, err := chargeCard(validated)
    if err != nil {
        return nil, fmt.Errorf("charge order %s: %w", id, err)
    }

    return receipt, nil
}
```
