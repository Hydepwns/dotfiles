---
title: Elixir Testing with ExUnit
impact: MEDIUM
impactDescription: reliable tests, no mock drift
tags: elixir, exunit, testing, no-mocks
---

# Elixir Testing with ExUnit

## Descriptive test names with describe/test blocks

Group related tests under `describe` using the function name. Each `test` name states the behavior, not the implementation.

### Incorrect -- flat tests, vague names

```elixir
defmodule AccountTest do
  use ExUnit.Case

  test "test1" do
    assert Account.create(%{email: "a@b.com", name: "Ada"}) |> elem(0) == :ok
  end

  test "create bad" do
    assert Account.create(%{}) |> elem(0) == :error
  end

  test "balance" do
    {:ok, account} = Account.create(%{email: "a@b.com", name: "Ada"})
    assert Account.balance(account) >= 0
  end
end
```

### Correct -- grouped with describe, clear behavior names

```elixir
defmodule AccountTest do
  use ExUnit.Case, async: true

  describe "create/1" do
    test "returns {:ok, account} with valid params" do
      assert {:ok, %Account{email: "a@b.com"}} =
               Account.create(%{email: "a@b.com", name: "Ada"})
    end

    test "returns {:error, changeset} when required fields are missing" do
      assert {:error, %Ecto.Changeset{}} = Account.create(%{})
    end
  end

  describe "balance/1" do
    test "returns zero for a new account" do
      {:ok, account} = Account.create(%{email: "a@b.com", name: "Ada"})
      assert Account.balance(account) == 0
    end
  end
end
```

---

## Real dependencies over mocks

Use real modules, in-memory adapters, or process-based isolation. Mox introduces coupling to implementation details and drifts from real behavior. Only use Mox when explicitly requested.

### Incorrect -- Mox stub that drifts from real behavior

```elixir
defmodule OrderServiceTest do
  use ExUnit.Case

  import Mox

  setup :verify_on_exit!

  test "places order" do
    PaymentMock
    |> expect(:charge, fn _card, _amount -> {:ok, "ch_fake"} end)

    InventoryMock
    |> expect(:reserve, fn _sku, _qty -> :ok end)

    assert {:ok, _order} = OrderService.place(%{sku: "ABC", qty: 2, card: "tok_123"})
  end
end
```

### Correct -- real dependencies with test database and process mailbox

```elixir
defmodule OrderServiceTest do
  use MyApp.DataCase, async: true

  test "places order, charges payment, and reserves inventory" do
    product = insert(:product, sku: "ABC", stock: 10)
    card = create_test_card()

    assert {:ok, order} = OrderService.place(%{sku: "ABC", qty: 2, card: card.token})
    assert order.status == :confirmed

    # Verify real side effects
    assert Repo.get!(Product, product.id).stock == 8
    assert_received {:payment_charged, ^card, 2}
  end
end
```

---

## assert_receive / assert_raise patterns

Use `assert_receive` for async message verification with explicit timeouts. Use `assert_raise` to verify specific exception types and messages.

### Incorrect -- manual receive with bare assertions

```elixir
test "notifies subscribers" do
  Notifier.broadcast(:price_update, %{pair: "ETH/USD", price: 3200})
  Process.sleep(100)

  receive do
    msg -> assert msg == {:price_update, %{pair: "ETH/USD", price: 3200}}
  end
end

test "raises on bad input" do
  try do
    Parser.parse!("<<<invalid>>>")
    flunk("should have raised")
  rescue
    e -> assert e.__struct__ == Parser.SyntaxError
  end
end
```

### Correct -- ExUnit assertion helpers

```elixir
test "notifies subscribers of price updates" do
  Notifier.subscribe(:price_update)
  Notifier.broadcast(:price_update, %{pair: "ETH/USD", price: 3200})

  assert_receive {:price_update, %{pair: "ETH/USD", price: 3200}}, 500
end

test "raises SyntaxError on malformed input" do
  assert_raise Parser.SyntaxError, ~r/unexpected token/, fn ->
    Parser.parse!("<<<invalid>>>")
  end
end
```

---

## Setup blocks and test context

Use `setup` to share expensive setup. Pass data through the test context map. Keep setup minimal -- only what multiple tests actually need.

### Incorrect -- duplicated setup in every test

```elixir
defmodule LedgerTest do
  use MyApp.DataCase

  test "credits increase balance" do
    account = Repo.insert!(%Account{name: "Alice", balance: 0})
    {:ok, account} = Ledger.credit(account, 500)
    assert account.balance == 500
  end

  test "debits decrease balance" do
    account = Repo.insert!(%Account{name: "Alice", balance: 0})
    {:ok, account} = Ledger.credit(account, 500)
    {:ok, account} = Ledger.debit(account, 200)
    assert account.balance == 300
  end
end
```

### Correct -- shared setup with context

```elixir
defmodule LedgerTest do
  use MyApp.DataCase, async: true

  setup do
    account = insert(:account, balance: 0)
    {:ok, account: account}
  end

  describe "credit/2" do
    test "increases balance by the given amount", %{account: account} do
      assert {:ok, %Account{balance: 500}} = Ledger.credit(account, 500)
    end
  end

  describe "debit/2" do
    test "decreases balance by the given amount", %{account: account} do
      {:ok, account} = Ledger.credit(account, 500)
      assert {:ok, %Account{balance: 300}} = Ledger.debit(account, 200)
    end

    test "returns error when funds are insufficient", %{account: account} do
      assert {:error, :insufficient_funds} = Ledger.debit(account, 100)
    end
  end
end
```
