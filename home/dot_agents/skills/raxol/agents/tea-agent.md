---
title: TEA Agent
impact: CRITICAL
impactDescription: Core agent abstraction that all other agent types build upon.
tags: raxol, agent, tea, elixir
---

# TEA Agent (`use Raxol.Agent`)

Message-driven agents implementing The Elm Architecture. Input comes from LLMs,
tools, or other agents instead of a keyboard.

## Setup

```elixir
defmodule MyAgent do
  use Raxol.Agent
  # Injects: @behaviour Raxol.Core.Runtime.Application
  # Imports: Raxol.Core.Renderer.View, Event, Command
  # Helpers: async/1, shell/2, send_agent/2, run_action/3,
  #          run_action_async/3, run_pipeline_async/3
end
```

## Core Callbacks

```elixir
def init(context) :: map()                        # initial model
def update(message, model) :: {model, Command.t()} # handle messages
def view(model) :: view_tree | nil                 # nil = headless
```

Agent-specific (override to customize):

```elixir
def available_actions() :: [module()]  # Action modules for Strategy
def command_hooks() :: [module()]      # command interception hooks
def compaction_config() :: %{          # auto-compact model.history
  max_tokens: 8_000, preserve_recent: 4, summary_max_tokens: 1_000
} | nil
```

## Command Helpers

```elixir
# Async work -- sender.(result) delivers {:command_result, result}
async(fn sender -> sender.(do_work()) end)

# Shell -- result: {:command_result, {:shell_result, %{output: _, exit_status: _}}}
shell("wc -l < file.txt")

# Message another agent -- target gets {:agent_message, this_id, payload}
send_agent(:other_agent, {:task, data})

# Actions (see actions-pipelines.md)
run_action(ReadFile, %{path: "/tmp/x"})            # sync
run_action_async(ReadFile, %{path: "/tmp/x"})       # async
run_pipeline_async([Step1, Step2], params)           # pipeline

Command.none()  # no-op
```

## Messaging

Three primitives via `Raxol.Agent.Comm` (see SKILL.md for message format reference):

```elixir
# Fire-and-forget -- target receives {:agent_message, from_id, payload}
:ok = Raxol.Agent.Comm.send(:target, payload)

# Sync request-reply (5s default timeout)
{:ok, reply} = Raxol.Agent.Comm.call(:target, message, 5_000)
# Target MUST: send(pid, {:agent_reply, ref, reply})

# Broadcast to team -- all agents receive {:team_broadcast, team_id, payload}
:ok = Raxol.Agent.Comm.broadcast_team(:team_id, payload)
```

INCORRECT: Forgetting Call Reply

```elixir
def update({:call, _pid, _ref, {:query, q}}, model) do
  {%{model | result: process(q)}, Command.none()}
  # BUG: caller blocks forever
end
```

CORRECT:

```elixir
def update({:call, pid, ref, {:query, q}}, model) do
  send(pid, {:agent_reply, ref, process(q)})
  {model, Command.none()}
end
```

INCORRECT: Sync Call Deadlock

```elixir
# Agent A update/2 calls B synchronously
# Agent B update/2 calls A synchronously -> deadlock
```

Break cycles with async `send_agent/2` for one direction.

INCORRECT: Bare Model Return

```elixir
def update(_, model), do: model  # wrong
```

CORRECT:

```elixir
def update(_, model), do: {model, Command.none()}
```

## Session API

```elixir
{:ok, pid} = Session.start_link(id: :agent, app_module: MyAgent, team_id: :opt)
:ok = Session.send_message(:agent, payload)
{:ok, model} = Session.get_model(:agent)
{:ok, tree} = Session.get_view_tree(:agent)
{:ok, tree} = Session.get_semantic_view(:agent)  # layout stripped, for LLMs
```

## Example

```elixir
defmodule ReviewAgent do
  use Raxol.Agent

  def init(_), do: %{findings: [], status: :idle}

  def update({:agent_message, _, {:review, files}}, model) do
    {%{model | status: :working},
     async(fn sender ->
       sender.({:done, Enum.map(files, &analyze/1)})
     end)}
  end

  def update({:command_result, {:done, results}}, model) do
    {%{model | findings: results, status: :done}, Command.none()}
  end

  def update(_, model), do: {model, Command.none()}

  defp analyze(path), do: %{path: path, lines: path |> File.read!() |> String.split("\n") |> length()}
end
```
