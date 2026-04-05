---
title: Go Table-Driven Tests
impact: HIGH
impactDescription: comprehensive coverage, easy to extend
tags: go, testing, table-driven, subtests, helper
---

# Go Table-Driven Tests

## Use table-driven tests with named cases and t.Run

Individual test functions per case are verbose and hard to extend. Table-driven
tests with `t.Run` give you named subtests, selective execution (`go test -run
TestParse/negative`), and parallel support.

INCORRECT:

```go
func TestParsePositive(t *testing.T) {
    got, err := Parse("42")
    if err != nil {
        t.Fatal(err)
    }
    if got != 42 {
        t.Errorf("got %d, want 42", got)
    }
}

func TestParseNegative(t *testing.T) {
    got, err := Parse("-7")
    if err != nil {
        t.Fatal(err)
    }
    if got != -7 {
        t.Errorf("got %d, want -7", got)
    }
}

func TestParseInvalid(t *testing.T) {
    _, err := Parse("abc")
    if err == nil {
        t.Fatal("expected error")
    }
}
```

CORRECT:

```go
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int
        wantErr bool
    }{
        {name: "positive", input: "42", want: 42},
        {name: "negative", input: "-7", want: -7},
        {name: "zero", input: "0", want: 0},
        {name: "invalid/letters", input: "abc", wantErr: true},
        {name: "invalid/empty", input: "", wantErr: true},
        {name: "invalid/overflow", input: "99999999999999999999", wantErr: true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if tt.wantErr {
                if err == nil {
                    t.Fatal("expected error, got nil")
                }
                return
            }
            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }
            if got != tt.want {
                t.Errorf("Parse(%q) = %d, want %d", tt.input, got, tt.want)
            }
        })
    }
}
```

## Use t.Helper() for test helper functions

Without `t.Helper()`, failures point to the line inside the helper, not the
line in the test that called it. This makes debugging painful.

INCORRECT:

```go
func assertStatusCode(t *testing.T, resp *http.Response, want int) {
    // failure reports this line, not the caller
    if resp.StatusCode != want {
        t.Errorf("status = %d, want %d", resp.StatusCode, want)
    }
}

func TestAPI(t *testing.T) {
    resp := doRequest("/health")
    assertStatusCode(t, resp, 200) // error points to assertStatusCode, not here
}
```

CORRECT:

```go
func assertStatusCode(t *testing.T, resp *http.Response, want int) {
    t.Helper()
    if resp.StatusCode != want {
        t.Errorf("status = %d, want %d", resp.StatusCode, want)
    }
}

func TestAPI(t *testing.T) {
    resp := doRequest("/health")
    assertStatusCode(t, resp, 200) // error points here
}
```

## Prefer stdlib assertions over testify

The standard library's `testing` package is expressive enough for most cases.
Testify adds a dependency, hides what's being compared behind method names,
and its diff output is often less clear than a simple `t.Errorf` with the
values spelled out.

INCORRECT:

```go
import "github.com/stretchr/testify/assert"

func TestCreateUser(t *testing.T) {
    user, err := CreateUser("alice", "alice@example.com")
    assert.NoError(t, err)
    assert.NotNil(t, user)
    assert.Equal(t, "alice", user.Name)
    assert.Equal(t, "alice@example.com", user.Email)
    assert.True(t, user.Active)
}
```

CORRECT:

```go
func TestCreateUser(t *testing.T) {
    user, err := CreateUser("alice", "alice@example.com")
    if err != nil {
        t.Fatalf("CreateUser: %v", err)
    }
    if user == nil {
        t.Fatal("CreateUser returned nil user")
    }

    if user.Name != "alice" {
        t.Errorf("Name = %q, want %q", user.Name, "alice")
    }
    if user.Email != "alice@example.com" {
        t.Errorf("Email = %q, want %q", user.Email, "alice@example.com")
    }
    if !user.Active {
        t.Error("Active = false, want true")
    }
}
```

## Test error cases with specific error checks

Don't just check `err != nil`. Verify the error is the one you expect. This
catches bugs where the function fails for the wrong reason.

INCORRECT:

```go
func TestLookup_NotFound(t *testing.T) {
    _, err := Lookup("nonexistent-id")
    if err == nil {
        t.Fatal("expected error")
    }
    // passes even if Lookup failed due to a database connection error
}
```

CORRECT:

```go
func TestLookup(t *testing.T) {
    tests := []struct {
        name    string
        id      string
        want    *Record
        wantErr error
    }{
        {
            name: "found",
            id:   "abc-123",
            want: &Record{ID: "abc-123", Value: "test"},
        },
        {
            name:    "not found",
            id:      "nonexistent-id",
            wantErr: ErrNotFound,
        },
        {
            name:    "invalid id format",
            id:      "",
            wantErr: ErrInvalidID,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Lookup(tt.id)
            if tt.wantErr != nil {
                if !errors.Is(err, tt.wantErr) {
                    t.Fatalf("Lookup(%q) error = %v, want %v", tt.id, err, tt.wantErr)
                }
                return
            }
            if err != nil {
                t.Fatalf("Lookup(%q): %v", tt.id, err)
            }
            if got.ID != tt.want.ID || got.Value != tt.want.Value {
                t.Errorf("Lookup(%q) = %+v, want %+v", tt.id, got, tt.want)
            }
        })
    }
}
```
