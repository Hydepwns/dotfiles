---
title: Rust Error Handling
impact: CRITICAL
impactDescription: type-safe errors, no panics in production
tags: rust, errors, thiserror, anyhow, result, from
---

# Rust Error Handling

## Use thiserror for library errors, anyhow for application errors

Libraries need typed errors so consumers can match on variants. Applications
need ergonomic error propagation with context. Mixing them up creates pain in
both directions.

INCORRECT:

```rust
// Library crate using anyhow -- consumers can't match on error kinds
pub fn parse_config(input: &str) -> anyhow::Result<Config> {
    let toml: toml::Value = input.parse()
        .context("bad toml")?;
    let port = toml.get("port")
        .ok_or_else(|| anyhow!("missing port"))?;
    // consumer has no way to programmatically distinguish
    // "bad toml" from "missing port"
    Ok(Config { port: port.as_integer().unwrap() as u16 })
}
```

CORRECT:

```rust
// Library crate -- typed errors with thiserror
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("invalid TOML: {0}")]
    InvalidToml(#[from] toml::de::Error),

    #[error("missing required field: {0}")]
    MissingField(&'static str),

    #[error("invalid value for {field}: {reason}")]
    InvalidValue { field: &'static str, reason: String },
}

pub fn parse_config(input: &str) -> Result<Config, ConfigError> {
    let toml: toml::Value = input.parse()?; // From<toml::de::Error>
    let port = toml.get("port")
        .ok_or(ConfigError::MissingField("port"))?;
    let port = port.as_integer()
        .ok_or_else(|| ConfigError::InvalidValue {
            field: "port",
            reason: "expected integer".into(),
        })?;
    Ok(Config { port: port as u16 })
}

// Application crate -- anyhow for ergonomic propagation
fn main() -> anyhow::Result<()> {
    let raw = std::fs::read_to_string("config.toml")
        .context("reading config file")?;
    let config = parse_config(&raw)
        .context("parsing config.toml")?;
    run_server(config)
}
```

## Add context with .context() instead of bare ?

Bare `?` propagates the error but loses the "what were we trying to do" frame.
Always add context at meaningful boundaries.

INCORRECT:

```rust
fn sync_user(id: UserId) -> anyhow::Result<()> {
    let user = db::fetch_user(id)?;        // "row not found"
    let profile = api::get_profile(id)?;    // "connection refused"
    db::update_user(user.merge(profile))?;  // "constraint violation"
    Ok(())
    // caller sees "connection refused" with no idea which step failed
}
```

CORRECT:

```rust
fn sync_user(id: UserId) -> anyhow::Result<()> {
    let user = db::fetch_user(id)
        .with_context(|| format!("fetch user {id} from db"))?;
    let profile = api::get_profile(id)
        .with_context(|| format!("fetch profile for user {id} from api"))?;
    db::update_user(user.merge(profile))
        .with_context(|| format!("update user {id} in db"))?;
    Ok(())
    // caller sees "fetch profile for user 42 from api: connection refused"
}
```

## Never use unwrap/expect/panic in production code paths

`unwrap()` and `expect()` compile but crash at runtime. Reserve them for tests
and cases with compile-time proof of correctness (e.g., regex literals). In
production, propagate with `?` or handle the None/Err explicitly.

INCORRECT:

```rust
fn get_setting(key: &str) -> String {
    let config = load_config().unwrap(); // panics if config missing
    let value = config.get(key).expect("setting must exist"); // panics
    value.to_string()
}

fn connect_db() -> Connection {
    let url = std::env::var("DATABASE_URL").unwrap(); // panics if unset
    Connection::new(&url).expect("db must connect")   // panics
}
```

CORRECT:

```rust
fn get_setting(key: &str) -> anyhow::Result<String> {
    let config = load_config()
        .context("loading config")?;
    let value = config.get(key)
        .ok_or_else(|| anyhow!("missing setting: {key}"))?;
    Ok(value.to_string())
}

fn connect_db() -> anyhow::Result<Connection> {
    let url = std::env::var("DATABASE_URL")
        .context("DATABASE_URL not set")?;
    Connection::new(&url)
        .context("connecting to database")
}

// unwrap is fine for proven-correct cases in non-production paths
#[cfg(test)]
fn test_regex() -> Regex {
    Regex::new(r"^\d{4}-\d{2}-\d{2}$").unwrap() // compile-time-known pattern
}
```

## Use #[from] for automatic From implementations

`thiserror`'s `#[from]` attribute generates `From` impls so the `?` operator
converts automatically. Don't write manual `From` impls or `.map_err()` calls
when `#[from]` works.

INCORRECT:

```rust
#[derive(Debug, thiserror::Error)]
pub enum StoreError {
    #[error("database error: {0}")]
    Database(sqlx::Error),

    #[error("serialization error: {0}")]
    Serialization(serde_json::Error),
}

pub fn save(record: &Record) -> Result<(), StoreError> {
    let json = serde_json::to_string(record)
        .map_err(StoreError::Serialization)?;   // manual conversion
    db::execute("INSERT INTO records (data) VALUES (?)", &json)
        .map_err(StoreError::Database)?;         // manual conversion
    Ok(())
}
```

CORRECT:

```rust
#[derive(Debug, thiserror::Error)]
pub enum StoreError {
    #[error("database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("serialization error: {0}")]
    Serialization(#[from] serde_json::Error),
}

pub fn save(record: &Record) -> Result<(), StoreError> {
    let json = serde_json::to_string(record)?;  // From<serde_json::Error>
    db::execute("INSERT INTO records (data) VALUES (?)", &json)?; // From<sqlx::Error>
    Ok(())
}
```
