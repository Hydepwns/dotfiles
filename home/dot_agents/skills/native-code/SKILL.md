---
name: native-code
description: >
  NIF (Native Implemented Functions) development and SIMD patterns for Elixir/BEAM.
  TRIGGER when: writing NIFs in C or Rust (Rustler), using erl_nif.h, Zig SIMD
  code for BEAM integration, tree-sitter grammar NIFs, or discussing native
  performance boundaries in Elixir. DO NOT TRIGGER when: general C/Zig/Rust
  language questions (use droo-stack), general Elixir patterns (use droo-stack),
  Raxol framework (use raxol skill).
metadata:
  author: hydepwns
  version: "1.0.0"
  tags: nif, simd, ffi, beam, erlang, elixir, rustler, zig, c, native
---

# native-code

Domain knowledge for building native extensions for the BEAM VM. Covers the
NIF boundary (C and Rust), SIMD via Zig, and the cross-cutting concerns that
apply regardless of implementation language.

For general language patterns (C, Zig, Rust), see droo-stack.

## When to use

- Writing or reviewing NIF code (C `erl_nif.h` or Rust Rustler)
- Integrating Zig SIMD routines into BEAM via C ABI
- Designing the Elixir-side module for a NIF
- Debugging scheduler issues, memory leaks, or crashes at the native boundary
- Building tree-sitter grammar parsers as NIFs
- Setting up precompiled NIF releases

## When NOT to use

- General C, Zig, or Rust coding -- use droo-stack
- General Elixir patterns -- use droo-stack
- Raxol TUI framework -- use raxol skill

## Reading guide

| Working on | Read |
|-----------|------|
| Scheduler contract, memory model, deployment | [references/boundary-patterns](references/boundary-patterns.md) |
| Elixir-side NIF module structure | [references/nif-elixir](references/nif-elixir.md) |
| C NIFs (`erl_nif.h`, resources, tree-sitter) | [references/nif-c](references/nif-c.md) |
| Rust NIFs (Rustler, ResourceArc, safety) | [references/nif-rust](references/nif-rust.md) |
| Zig SIMD (`@Vector`, reductions, NIF integration) | [references/simd-zig](references/simd-zig.md) |

## Key principles

1. **Never block the BEAM scheduler** -- NIFs must return within 1ms or use dirty schedulers
2. **The BEAM owns terms, you own native memory** -- never store `ERL_NIF_TERM` across NIF calls
3. **Crash in NIF = crash the entire VM** -- no panics (Rust), no segfaults, no undefined behavior
4. **Test at two levels** -- native unit tests (cargo test, zig test) AND ExUnit boundary tests
5. **Zero-copy where possible** -- use BEAM binaries for large data transfer

## Common pitfalls

| Mistake | Impact | Fix |
|---------|--------|-----|
| NIF takes >1ms without dirty scheduler | Scheduler starvation, latency spikes | Add `ERL_NIF_DIRTY_JOB_CPU_BOUND` or `schedule = "DirtyCpu"` |
| Storing `ERL_NIF_TERM` in native struct | Use-after-free, undefined behavior | Copy data out of terms, or use `enif_make_copy` with a process-independent env |
| Rust `panic!` / `unwrap()` inside NIF | Entire BEAM VM crashes | Use `Result`, catch panics at boundary with `std::panic::catch_unwind` |
| Missing NIF stub in Elixir module | Silent `nil` return or confusing error | Stub must `raise "NIF not loaded"` |
| Not freeing native resources | Memory leak proportional to call rate | Register destructors via resource types |

## See also

- droo-stack -- C, Zig, Rust language patterns
- raxol -- Elixir TUI framework (potential NIF consumer)
- nix -- packaging native deps with Nix (buildRustPackage, mkDerivation)
