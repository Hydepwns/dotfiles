---
title: Rust NIF Implementation with Rustler
impact: CRITICAL
impactDescription: Defines Rust NIF project setup, type mappings, and safe BEAM interop using the Rustler crate.
tags: nif, rust, rustler, beam, native
---

# Rust NIF Patterns (Rustler)

NIFs written in Rust using the Rustler crate.

## Project setup

```toml
# native/my_nif/Cargo.toml
[package]
name = "my_nif"
version = "0.1.0"
edition = "2021"

[lib]
name = "my_nif"
crate-type = ["cdylib"]

[dependencies]
rustler = "0.34"
```

## Basic NIF function

```rust
#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

rustler::init!("Elixir.MyApp.Math");
```

Rustler auto-registers functions annotated with `#[rustler::nif]`.

## Type mapping

| Elixir | Rust (Rustler) |
|--------|----------------|
| integer | `i64`, `u64`, `i32`, etc. |
| float | `f64` |
| binary | `Binary`, `OwnedBinary`, `&[u8]` |
| string | `String`, `&str` |
| atom | `Atom`, `rustler::atoms!` |
| list | `Vec<T>`, `ListIterator` |
| tuple | `(A, B, C)` |
| map | `HashMap<K, V>`, `Term` |
| nil | `()` or `Option<T>` (None) |
| resource | `ResourceArc<T>` |

## Returning tagged tuples

```rust
mod atoms {
    rustler::atoms! {
        ok,
        error,
        invalid_input,
        overflow,
    }
}

#[rustler::nif]
fn process(data: Binary) -> Result<(Atom, OwnedBinary), (Atom, Atom)> {
    if data.is_empty() {
        return Err((atoms::error(), atoms::invalid_input()));
    }

    let result = do_work(data.as_slice())
        .map_err(|_| (atoms::error(), atoms::overflow()))?;

    let mut output = OwnedBinary::new(result.len())
        .ok_or((atoms::error(), atoms::overflow()))?;
    output.as_mut_slice().copy_from_slice(&result);

    Ok((atoms::ok(), output))
}
```

## Resource objects

For native state managed by BEAM GC:

```rust
use rustler::ResourceArc;
use std::sync::Mutex;

struct ParserInner {
    // tree-sitter parser, connection handle, etc.
    data: Vec<u8>,
}

#[rustler::resource]
struct Parser {
    inner: Mutex<ParserInner>,
}

#[rustler::nif]
fn parser_new() -> ResourceArc<Parser> {
    ResourceArc::new(Parser {
        inner: Mutex::new(ParserInner { data: vec![] }),
    })
}

#[rustler::nif]
fn parser_parse(parser: ResourceArc<Parser>, input: Binary) -> Result<(Atom, Binary), (Atom, Atom)> {
    let mut inner = parser.inner.lock()
        .map_err(|_| (atoms::error(), atoms::lock_failed()))?;
    // use inner.data, input.as_slice()
    // ...
}
```

**Important:** `ResourceArc<T>` requires `T: Send + Sync`. Use `Mutex` or
`RwLock` for interior mutability.

## Dirty scheduler

```rust
// CPU-bound work (> 1ms)
#[rustler::nif(schedule = "DirtyCpu")]
fn heavy_compute(data: Binary) -> (Atom, OwnedBinary) {
    // long-running computation
}

// I/O-bound work
#[rustler::nif(schedule = "DirtyIo")]
fn read_large_file(path: String) -> Result<(Atom, OwnedBinary), (Atom, String)> {
    // file I/O
}
```

## Panic safety

### Incorrect: unwrap inside NIF

```rust
// Incorrect -- panic kills the entire BEAM VM
#[rustler::nif]
fn parse(data: Binary) -> String {
    let text = std::str::from_utf8(data.as_slice()).unwrap();  // PANIC on invalid UTF-8
    text.to_uppercase()
}
```

### Correct: handle errors explicitly

```rust
// Correct -- return error tuple
#[rustler::nif]
fn parse(data: Binary) -> Result<(Atom, String), (Atom, Atom)> {
    let text = std::str::from_utf8(data.as_slice())
        .map_err(|_| (atoms::error(), atoms::invalid_utf8()))?;
    Ok((atoms::ok(), text.to_uppercase()))
}
```

For cases where you call into code that might panic (e.g., third-party crates):

```rust
#[rustler::nif]
fn risky_call(input: i64) -> Result<(Atom, i64), (Atom, String)> {
    match std::panic::catch_unwind(|| third_party::compute(input)) {
        Ok(result) => Ok((atoms::ok(), result)),
        Err(_) => Err((atoms::error(), "native panic caught".to_string())),
    }
}
```

## Binary handling

```rust
// Zero-copy read from Elixir binary
#[rustler::nif]
fn checksum(data: Binary) -> u32 {
    crc32fast::hash(data.as_slice())
}

// Create new binary to return
#[rustler::nif]
fn compress(data: Binary) -> Result<(Atom, OwnedBinary), (Atom, Atom)> {
    let compressed = miniz_oxide::deflate::compress_to_vec(data.as_slice(), 6);

    let mut output = OwnedBinary::new(compressed.len())
        .ok_or((atoms::error(), atoms::alloc_failed()))?;
    output.as_mut_slice().copy_from_slice(&compressed);

    Ok((atoms::ok(), output))
}
```

## Unsafe boundaries

Keep `unsafe` minimal and wrap it in safe APIs:

```rust
// Incorrect -- unsafe spread throughout
#[rustler::nif]
fn call_c_lib(data: Binary) -> i32 {
    unsafe {
        let ptr = data.as_slice().as_ptr() as *const c_void;
        let len = data.as_slice().len() as c_int;
        ffi::process_data(ptr, len)  // unsafe call exposed directly
    }
}

// Correct -- unsafe contained in a safe wrapper
fn process_data_safe(data: &[u8]) -> Result<i32, &'static str> {
    if data.is_empty() {
        return Err("empty input");
    }
    // Safety: data pointer is valid for data.len() bytes,
    // process_data does not store the pointer
    let result = unsafe {
        ffi::process_data(data.as_ptr() as *const c_void, data.len() as c_int)
    };
    if result < 0 {
        Err("processing failed")
    } else {
        Ok(result)
    }
}

#[rustler::nif]
fn call_c_lib(data: Binary) -> Result<(Atom, i32), (Atom, Atom)> {
    process_data_safe(data.as_slice())
        .map(|r| (atoms::ok(), r))
        .map_err(|_| (atoms::error(), atoms::processing_failed()))
}
```

## Calling Zig SIMD from Rust NIF

When Zig provides the SIMD implementation via C ABI:

```rust
// Zig compiles to libmysimd.so with C ABI exports
extern "C" {
    fn simd_process(input: *const u8, len: usize, output: *mut u8) -> i32;
}

fn simd_process_safe(input: &[u8], output: &mut [u8]) -> Result<(), &'static str> {
    if output.len() < input.len() {
        return Err("output buffer too small");
    }
    let result = unsafe {
        simd_process(input.as_ptr(), input.len(), output.as_mut_ptr())
    };
    if result != 0 { Err("simd failed") } else { Ok(()) }
}
```
