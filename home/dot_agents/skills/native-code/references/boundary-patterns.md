---
title: NIF Boundary and BEAM Scheduler Safety
impact: CRITICAL
impactDescription: Cross-language NIF rules for scheduler contracts, dirty scheduling, yielding, and memory safety.
tags: nif, boundary, safety, scheduling, memory
---

# NIF Boundary Patterns

Cross-cutting concerns that apply to all NIF implementations regardless of
native language (C, Rust, Zig).

## The BEAM scheduler contract

The BEAM runs one scheduler thread per CPU core. Each scheduler picks a process,
runs its code, and moves on. A NIF that blocks a scheduler thread blocks
everything queued behind it.

**The 1ms rule**: if your NIF takes more than ~1ms, it must run on a dirty scheduler.

```
Work duration    | Strategy
< 1ms            | Regular NIF (default)
1ms - 100ms      | Dirty CPU scheduler
> 100ms          | Yielding NIF or port driver
I/O bound       | Dirty I/O scheduler
```

For C: annotate with `ERL_NIF_DIRTY_JOB_CPU_BOUND` or `ERL_NIF_DIRTY_JOB_IO_BOUND`.
For Rust (Rustler): `#[rustler::nif(schedule = "DirtyCpu")]`.

### Yielding NIFs (long work)

For work that takes hundreds of milliseconds, split into chunks and yield:

```c
// C yielding NIF pattern
static ERL_NIF_TERM continue_work(ErlNifEnv *env, int argc,
                                   const ERL_NIF_TERM argv[]) {
    WorkState *state = /* recover state */;
    int timeslice = 0;

    while (state->remaining > 0 && timeslice < 100) {
        process_chunk(state);
        timeslice++;
    }

    if (state->remaining > 0) {
        // More work -- yield and reschedule
        return enif_schedule_nif(env, "continue_work", 0,
                                 continue_work, argc, argv);
    }
    return enif_make_atom(env, "done");
}
```

## Memory model

Two memory worlds that must not leak into each other:

| | BEAM (managed) | Native (manual) |
|-|----------------|-----------------|
| **Allocator** | BEAM GC | malloc/Allocator/Box |
| **Lifetime** | process-scoped | explicit free or RAII |
| **Thread safety** | process isolation | your responsibility |
| **Cleanup** | automatic GC | resource destructors |

**Critical rules:**

1. Never store `ERL_NIF_TERM` in native memory -- terms are only valid for the
   duration of one NIF call. If you need to keep data, copy it to native types.
2. Never return a pointer to native memory as a term -- wrap it in a resource object.
3. BEAM binaries can be zero-copy shared via `enif_inspect_binary`, but the
   binary becomes invalid if the process GCs. For long-lived references, copy.

## Binary sharing

For large data transfer between Elixir and native code, use BEAM binaries:

```
Strategy          | When to use
enif_inspect_binary | Read-only access to Elixir binary (zero-copy)
enif_make_binary    | Return new binary to Elixir (NIF allocates)
enif_make_sub_binary| Return a slice of existing binary (zero-copy)
enif_alloc_binary   | Pre-allocate binary, fill in native code
```

For SIMD: allocate aligned buffers natively, process them, then copy results
into a BEAM binary for return. The copy cost is usually dwarfed by the SIMD
speedup.

## Error propagation

Native errors must become Elixir `{:error, reason}` tuples:

```
// C
enif_make_tuple2(env,
    enif_make_atom(env, "error"),
    enif_make_atom(env, "invalid_input"));

// Rust (Rustler)
Err(rustler::Error::Term(Box::new(atoms::invalid_input())))

// Zig (via C ABI wrapper)
return make_error_tuple(env, "invalid_input");
```

**Never panic/abort/segfault** -- it kills the entire BEAM VM, taking all
processes with it.

## Testing strategy

Test at two levels:

### Level 1: Native unit tests

Test the computation logic in isolation, without the BEAM:

```bash
# Rust
cargo test

# Zig
zig test src/simd.zig

# C (with your test framework of choice)
make test
```

### Level 2: ExUnit boundary tests

Test the NIF loading, term encoding/decoding, and error paths:

```elixir
defmodule MyNif.BoundaryTest do
  use ExUnit.Case

  test "returns {:error, _} for invalid input" do
    assert {:error, :invalid_input} = MyNif.process(<<>>)
  end

  test "handles large binaries without crash" do
    big = :crypto.strong_rand_bytes(10_000_000)
    assert is_binary(MyNif.process(big))
  end
end
```

### Level 3: Property-based roundtrip tests

Use StreamData to verify encoding/decoding is lossless:

```elixir
property "roundtrip: encode then decode returns original" do
  check all data <- binary() do
    assert data == MyNif.decode(MyNif.encode(data))
  end
end
```

## Deployment

### Precompiled NIFs (Rust)

Use `rustler_precompiled` to ship binaries for common targets:

```elixir
# mix.exs
defp deps do
  [{:rustler_precompiled, "~> 0.7"}, {:rustler, "~> 0.34", optional: true}]
end
```

Build matrix: `x86_64-linux-gnu`, `aarch64-linux-gnu`, `x86_64-apple-darwin`,
`aarch64-apple-darwin`. CI builds all targets on tag push.

### Precompiled NIFs (C/Zig)

No standard tooling -- use `elixir_make` with precompiled archives:

```elixir
# mix.exs
defp deps do
  [{:elixir_make, "~> 0.8"}]
end
```

### OTP version compatibility

NIF API versions are tied to OTP releases. Always specify the minimum OTP
version in your `mix.exs` and test against it in CI.
