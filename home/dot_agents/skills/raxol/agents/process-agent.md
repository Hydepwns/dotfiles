---
title: Process Agent (Observe/Think/Act)
impact: HIGH
impactDescription: Autonomous agents require correct lifecycle handling to avoid silent failures.
tags: raxol, agent, process, autonomous
---

# Process Agent (`use Raxol.Agent.UseProcess`)

Tick-driven autonomous agents with an observe/think/act loop. Use when the
agent should run continuously without UI and optionally integrate with an
AI Strategy for LLM-driven tool loops.

## Callbacks

```elixir
# Required
@callback init(keyword()) :: {:ok, state()} | state()
@callback observe([event], state()) :: {:ok, observation :: map(), state()}
@callback think(observation, state()) ::
  {:act, action, state()} | {:wait, state()} | {:ask_pilot, question, state()}
@callback act(action, state()) :: {:ok, state()} | {:error, reason, state()}
@callback receive_directive(directive, state()) :: {:ok, state()} | {:defer, state()}

# Optional -- crash recovery
@callback context_snapshot(state()) :: map()
@callback restore_context(map()) :: {:ok, state()} | :error

# Optional -- pilot takeover
@callback on_takeover(state()) :: {:ok, state()}
@callback on_resume(state()) :: {:ok, state()}
```

## Process.start_link

```elixir
{:ok, pid} = Raxol.Agent.Process.start_link(
  agent_id: :my_agent,           # required
  agent_module: MyAgent,          # required
  backend: Backend.Mock,          # default: Backend.Mock
  backend_config: [],             # opts for backend
  tick_ms: 1_000,                 # tick interval (default: 1000)
  strategy: Strategy.ReAct,       # optional, enables LLM tool loop
  pane_id: :my_pane               # optional, for Orchestrator
)
```

## Lifecycle

1. Start: loads `ContextStore.load(agent_id)` -> `restore_context/1`, else `init/1`
2. Every tick: `observe/2` -> `think/2` -> `act/2` (skipped when `:paused` or `:taken_over`)
3. If strategy is set and action is `{ActionModule, params}`, delegates to Strategy
4. After `act`: auto-compacts `model.history` if `compaction_config/0` is defined
5. Terminate/crash: saves `context_snapshot/1` to ContextStore

## think/2 Return Values

INCORRECT:

```elixir
def think(_, state), do: {:ok, state}  # wrong -- that's act's format
```

CORRECT:

```elixir
def think(%{needs_work: true}, state), do: {:act, :do_work, state}
def think(_, state), do: {:wait, state}
```

## Crash Recovery

Implement `context_snapshot/1` and `restore_context/1` or state is lost on
restart. Both are optional callbacks with identity defaults.

## Client API

```elixir
Process.send_directive(pid_or_id, directive)  # async
Process.takeover(pid_or_id)                   # pilot takes over
Process.release(pid_or_id)                    # pilot releases
Process.get_status(pid_or_id)                 # %{status: atom, ...}
Process.push_event(pid_or_id, event)          # into next observe cycle
```

Status: `:initializing`, `:thinking`, `:acting`, `:waiting`, `:paused`, `:taken_over`

## Example

```elixir
defmodule Watchdog do
  use Raxol.Agent.UseProcess

  @impl true
  def init(_), do: {:ok, %{checks: 0, alerts: []}}

  @impl true
  def observe(events, state) do
    {:ok, %{alerts: Enum.filter(events, &match?({:alert, _}, &1))}, state}
  end

  @impl true
  def think(%{alerts: [_ | _]} = obs, state), do: {:act, {:handle, obs.alerts}, state}
  def think(_, state), do: {:wait, state}

  @impl true
  def act({:handle, alerts}, state) do
    {:ok, %{state | alerts: alerts ++ state.alerts, checks: state.checks + 1}}
  end

  @impl true
  def context_snapshot(state), do: state

  @impl true
  def restore_context(snapshot), do: {:ok, snapshot}
end
```
