---
title: Elixir Functional Patterns
impact: HIGH
impactDescription: cleaner control flow, better error handling
tags: elixir, with, pipes, pattern-matching, guards
---

# Elixir Functional Patterns

## `with` chains over nested `case`

Use `with` for multi-step operations that depend on each other. Nested `case` creates rightward drift and obscures the happy path.

### Incorrect -- nested case statements

```elixir
def create_account(params) do
  case validate(params) do
    {:ok, validated} ->
      case Repo.insert(changeset(validated)) do
        {:ok, user} ->
          case Mailer.send_welcome(user) do
            {:ok, _email} ->
              {:ok, user}

            {:error, reason} ->
              {:error, {:email_failed, reason}}
          end

        {:error, changeset} ->
          {:error, {:insert_failed, changeset}}
      end

    {:error, errors} ->
      {:error, {:validation_failed, errors}}
  end
end
```

### Correct -- with chain, flat and readable

```elixir
def create_account(params) do
  with {:ok, validated} <- validate(params),
       {:ok, user} <- Repo.insert(changeset(validated)),
       {:ok, _email} <- Mailer.send_welcome(user) do
    {:ok, user}
  else
    {:error, %Ecto.Changeset{} = changeset} -> {:error, {:insert_failed, changeset}}
    {:error, reason} -> {:error, reason}
  end
end
```

---

## Pipe operator idioms

Data flows left to right. The subject is always the first argument. Do not embed side effects (logging, metrics) in the middle of a data-transformation pipeline.

### Incorrect -- side effects in pipeline, non-data-first functions

```elixir
def process_order(raw_params) do
  raw_params
  |> Map.get(:items)
  |> Enum.map(&fetch_price/1)
  |> IO.inspect(label: "prices")
  |> Enum.reduce(0, &Kernel.+/2)
  |> apply_discount(raw_params[:coupon])
  |> tap(fn total -> Metrics.emit("order.total", total) end)
  |> create_invoice(raw_params[:customer_id])
end
```

### Correct -- pure pipeline for transforms, side effects separate

```elixir
def process_order(raw_params) do
  total =
    raw_params
    |> Map.fetch!(:items)
    |> Enum.map(&fetch_price/1)
    |> Enum.sum()
    |> apply_discount(raw_params[:coupon])

  Metrics.emit("order.total", total)
  create_invoice(total, raw_params[:customer_id])
end
```

---

## Pattern matching in function heads vs guard clauses

Use multi-clause function heads to dispatch on structure. Use guards for value constraints that cannot be expressed via pattern matching alone.

### Incorrect -- single function with cond/if for dispatch

```elixir
def handle_response(response) do
  cond do
    is_map(response) and Map.has_key?(response, :data) ->
      {:ok, response.data}

    is_map(response) and Map.has_key?(response, :error) ->
      {:error, response.error}

    is_nil(response) ->
      {:error, :empty}

    true ->
      {:error, :unknown}
  end
end
```

### Correct -- multi-clause with pattern matching and guards

```elixir
def handle_response(%{data: data}), do: {:ok, data}
def handle_response(%{error: reason}), do: {:error, reason}
def handle_response(nil), do: {:error, :empty}
def handle_response(_other), do: {:error, :unknown}
```

---

## Multi-clause functions over if/cond

When behavior branches on argument shape, prefer separate function clauses. Reserve `if` for simple boolean checks inside a single clause. Reserve `cond` only when matching against computed values that cannot appear in function heads.

### Incorrect -- if/cond inside a single function

```elixir
def format_user(user) do
  if user.role == :admin do
    "#{user.name} [ADMIN]"
  else
    if user.active do
      user.name
    else
      "#{user.name} (inactive)"
    end
  end
end
```

### Correct -- multi-clause with guards

```elixir
def format_user(%{role: :admin, name: name}), do: "#{name} [ADMIN]"
def format_user(%{active: true, name: name}), do: name
def format_user(%{name: name}), do: "#{name} (inactive)"
```
