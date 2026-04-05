---
title: Rust Idiomatic Patterns
impact: HIGH
impactDescription: idiomatic, clippy-clean, zero-cost abstractions
tags: rust, builder, derive, clippy, iterators, traits
---

# Rust Idiomatic Patterns

## Derive traits liberally

Missing derives force consumers to write boilerplate. Derive the standard set
unless there's a specific reason not to (e.g., a type containing a raw pointer).

INCORRECT:

```rust
struct Endpoint {
    host: String,
    port: u16,
    tls: bool,
}

// Cannot println!("{:?}", endpoint) -- no Debug
// Cannot endpoint == other -- no PartialEq
// Cannot use in HashSet -- no Hash
// Cannot clone from a shared reference -- no Clone
```

CORRECT:

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Endpoint {
    host: String,
    port: u16,
    tls: bool,
}

// For data types that also need serialization:
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
struct Config {
    endpoints: Vec<Endpoint>,
    timeout_ms: u64,
}
```

## Use iterator chains over explicit loops

Iterator chains are more expressive, less error-prone (no off-by-one), and
the compiler optimizes them to the same machine code as manual loops.

INCORRECT:

```rust
fn active_emails(users: &[User]) -> Vec<String> {
    let mut result = Vec::new();
    for i in 0..users.len() {
        if users[i].active {
            let email = users[i].email.to_lowercase();
            if !result.contains(&email) {
                result.push(email);
            }
        }
    }
    result.sort();
    result
}
```

CORRECT:

```rust
fn active_emails(users: &[User]) -> Vec<String> {
    let mut emails: Vec<String> = users.iter()
        .filter(|u| u.active)
        .map(|u| u.email.to_lowercase())
        .collect::<HashSet<_>>() // deduplicate
        .into_iter()
        .collect();
    emails.sort();
    emails
}
```

## Builder pattern for complex construction

Types with many optional fields should use a builder instead of constructors
with long argument lists or public fields. This makes call sites readable and
lets you validate at build time.

INCORRECT:

```rust
struct Server {
    pub host: String,
    pub port: u16,
    pub max_connections: usize,
    pub timeout: Duration,
    pub tls_cert: Option<PathBuf>,
    pub tls_key: Option<PathBuf>,
}

// Call site -- unclear which number is which
let server = Server {
    host: "0.0.0.0".into(),
    port: 8080,
    max_connections: 1000,
    timeout: Duration::from_secs(30),
    tls_cert: Some("/etc/cert.pem".into()),
    tls_key: Some("/etc/key.pem".into()),
};
```

CORRECT:

```rust
#[derive(Debug, Clone)]
pub struct Server {
    host: String,
    port: u16,
    max_connections: usize,
    timeout: Duration,
    tls_cert: Option<PathBuf>,
    tls_key: Option<PathBuf>,
}

#[derive(Debug, Clone)]
pub struct ServerBuilder {
    host: String,
    port: u16,
    max_connections: usize,
    timeout: Duration,
    tls_cert: Option<PathBuf>,
    tls_key: Option<PathBuf>,
}

impl ServerBuilder {
    pub fn new(host: impl Into<String>, port: u16) -> Self {
        Self {
            host: host.into(),
            port,
            max_connections: 100,
            timeout: Duration::from_secs(30),
            tls_cert: None,
            tls_key: None,
        }
    }

    pub fn max_connections(mut self, n: usize) -> Self {
        self.max_connections = n;
        self
    }

    pub fn timeout(mut self, d: Duration) -> Self {
        self.timeout = d;
        self
    }

    pub fn tls(mut self, cert: impl Into<PathBuf>, key: impl Into<PathBuf>) -> Self {
        self.tls_cert = Some(cert.into());
        self.tls_key = Some(key.into());
        self
    }

    pub fn build(self) -> Result<Server, ConfigError> {
        if self.tls_cert.is_some() != self.tls_key.is_some() {
            return Err(ConfigError::IncompleteTls);
        }
        Ok(Server {
            host: self.host,
            port: self.port,
            max_connections: self.max_connections,
            timeout: self.timeout,
            tls_cert: self.tls_cert,
            tls_key: self.tls_key,
        })
    }
}

// Call site -- clear, validated
let server = ServerBuilder::new("0.0.0.0", 8080)
    .max_connections(1000)
    .tls("/etc/cert.pem", "/etc/key.pem")
    .build()?;
```

## Accept references, return owned values

Functions that only read data should accept borrows (`&T`, `&str`, `&[T]`).
Functions that produce data should return owned types. This gives callers
maximum flexibility without unnecessary cloning.

INCORRECT:

```rust
// Takes ownership unnecessarily -- caller must clone
fn summarize(items: Vec<Order>) -> Summary {
    let total = items.iter().map(|o| o.amount).sum();
    let count = items.len();
    Summary { total, count }
}

// Returns a reference tied to internal state -- limits caller
fn get_name(&self) -> &str {
    &self.first // caller can't store this past self's lifetime
}

// Usage forces a clone even though summarize only reads
let summary = summarize(orders.clone());
println!("{:?}", orders); // need orders again
```

CORRECT:

```rust
// Borrows -- caller keeps ownership
fn summarize(items: &[Order]) -> Summary {
    let total = items.iter().map(|o| o.amount).sum();
    let count = items.len();
    Summary { total, count }
}

// Returns owned -- caller has full control
fn full_name(&self) -> String {
    format!("{} {}", self.first, self.last)
}

// No clone needed
let summary = summarize(&orders);
println!("{:?}", orders); // still available
```

## Organize impl blocks by concern

Group inherent methods, trait implementations, and private helpers into
separate `impl` blocks. This makes large types navigable.

INCORRECT:

```rust
impl Cache {
    pub fn new(capacity: usize) -> Self { /* ... */ }
    fn evict_oldest(&mut self) { /* ... */ }
    pub fn get(&self, key: &str) -> Option<&Value> { /* ... */ }
    fn hash_key(&self, key: &str) -> u64 { /* ... */ }
    pub fn insert(&mut self, key: String, value: Value) { /* ... */ }
    pub fn len(&self) -> usize { /* ... */ }
    pub fn is_empty(&self) -> bool { /* ... */ }
}

impl fmt::Display for Cache {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result { /* ... */ }
}

impl Drop for Cache {
    fn drop(&mut self) { /* ... */ }
}
```

CORRECT:

```rust
// -- Construction and public API --
impl Cache {
    pub fn new(capacity: usize) -> Self { /* ... */ }
    pub fn get(&self, key: &str) -> Option<&Value> { /* ... */ }
    pub fn insert(&mut self, key: String, value: Value) { /* ... */ }
    pub fn len(&self) -> usize { /* ... */ }
    pub fn is_empty(&self) -> bool { /* ... */ }
}

// -- Internal helpers --
impl Cache {
    fn evict_oldest(&mut self) { /* ... */ }
    fn hash_key(&self, key: &str) -> u64 { /* ... */ }
}

// -- Trait implementations --
impl fmt::Display for Cache {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result { /* ... */ }
}

impl Drop for Cache {
    fn drop(&mut self) { /* ... */ }
}
```
