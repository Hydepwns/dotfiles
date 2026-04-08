---
title: NIF Elixir-Side Wrapper Patterns
impact: CRITICAL
impactDescription: Defines the Elixir module structure and conventions for wrapping C and Rust NIFs.
tags: nif, elixir, beam, native, boundary
---

# NIF Elixir-Side Patterns

The Elixir module that wraps a NIF. This is the boundary users interact with.

## Module structure (C NIF)

```elixir
defmodule MyApp.Native do
  @on_load :load_nifs

  @doc false
  def load_nifs do
    path = :filename.join(:code.priv_dir(:my_app), ~c"my_nif")
    :erlang.load_nif(path, 0)
  end

  @doc """
  Process binary data using native implementation.

  Implemented as a NIF -- runs on a dirty CPU scheduler for inputs > 1KB.
  """
  @spec process(binary()) :: {:ok, binary()} | {:error, atom()}
  def process(_data) do
    raise "NIF my_nif not loaded"
  end
end
```

### Incorrect: silent fallback

```elixir
# Incorrect -- returns nil silently when NIF isn't loaded
def process(_data), do: nil

# Incorrect -- returns a fallback that hides the problem
def process(data), do: {:ok, data}
```

### Correct: loud failure

```elixir
# Correct -- fail fast with clear error
def process(_data) do
  raise "NIF my_nif not loaded"
end
```

## Module structure (Rustler)

```elixir
defmodule MyApp.Native do
  use Rustler,
    otp_app: :my_app,
    crate: "my_nif"

  @doc """
  SIMD-accelerated hash computation.

  Implemented as a NIF (Rust/Rustler). Runs on dirty CPU scheduler.
  """
  @spec hash(binary()) :: {:ok, binary()} | {:error, atom()}
  def hash(_data), do: :erlang.nif_error(:nif_not_loaded)
end
```

### With RustlerPrecompiled

```elixir
defmodule MyApp.Native do
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :my_app,
    crate: "my_nif",
    base_url: "https://github.com/user/repo/releases/download/v#{version}",
    version: version,
    force_build: System.get_env("FORCE_NIF_BUILD") in ["1", "true"]

  @spec hash(binary()) :: {:ok, binary()} | {:error, atom()}
  def hash(_data), do: :erlang.nif_error(:nif_not_loaded)
end
```

## Mix project configuration

### For C NIFs (elixir_make)

```elixir
# mix.exs
defp deps do
  [{:elixir_make, "~> 0.8", runtime: false}]
end

def project do
  [
    compilers: [:elixir_make] ++ Mix.compilers(),
    make_targets: ["all"],
    make_clean: ["clean"],
    # ...
  ]
end
```

Requires a `Makefile` in the project root that builds to `priv/my_nif.so`.

### For Rust NIFs (Rustler)

```elixir
# mix.exs
defp deps do
  [{:rustler, "~> 0.34", runtime: false}]
end
```

Cargo project lives in `native/my_nif/`.

## Loading in application start

For NIFs that must be available before any module call:

```elixir
# application.ex
def start(_type, _args) do
  # Ensure NIF is loaded before supervision tree starts
  case MyApp.Native.load_nifs() do
    :ok -> :ok
    {:error, reason} ->
      require Logger
      Logger.warning("NIF load failed: #{inspect(reason)}, using fallback")
  end

  children = [
    # ...
  ]

  Supervisor.start_link(children, strategy: :one_for_one)
end
```

## Typespecs for NIFs

Always add `@spec` -- NIFs have no Elixir source to infer types from:

```elixir
# Incorrect -- no spec, dialyzer can't check callers
def encode(data), do: :erlang.nif_error(:nif_not_loaded)

# Correct -- spec documents the contract
@spec encode(binary()) :: {:ok, binary()} | {:error, :invalid_input}
def encode(_data), do: :erlang.nif_error(:nif_not_loaded)
```

## Multi-function NIF modules

Group related NIFs in one module. Each function maps to one C/Rust function:

```elixir
defmodule MyApp.Codec do
  use Rustler, otp_app: :my_app, crate: "codec"

  @spec encode(term()) :: {:ok, binary()} | {:error, atom()}
  def encode(_term), do: :erlang.nif_error(:nif_not_loaded)

  @spec decode(binary()) :: {:ok, term()} | {:error, atom()}
  def decode(_binary), do: :erlang.nif_error(:nif_not_loaded)

  @spec batch_encode([term()]) :: {:ok, [binary()]} | {:error, atom()}
  def batch_encode(_terms), do: :erlang.nif_error(:nif_not_loaded)
end
```

Keep NIF modules thin -- business logic belongs in regular Elixir modules
that call these.
