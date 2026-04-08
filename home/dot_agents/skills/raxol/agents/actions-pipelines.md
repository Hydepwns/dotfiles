---
title: Actions and Pipelines
impact: HIGH
impactDescription: Actions bridge agents to LLM tool use and must return correct types to avoid runtime crashes.
tags: raxol, agent, action, pipeline, tools
---

# Actions and Pipelines

Reusable, schema-validated operations that compose into pipelines and
auto-convert to LLM tool definitions.

## Defining an Action

```elixir
defmodule ReadFile do
  use Raxol.Agent.Action,
    name: "read_file",
    description: "Read a file from disk",
    schema: [
      input: [path: [type: :string, required: true, description: "File path"]],
      output: [content: [type: :string], line_count: [type: :integer]]
    ]

  @impl true
  def run(%{path: path}, _context) do
    case File.read(path) do
      {:ok, content} ->
        {:ok, %{content: content, line_count: length(String.split(content, "\n"))}}
      {:error, reason} ->
        {:error, {:file_read_failed, reason}}
    end
  end
end
```

Schema types: `:string`, `:integer`, `:boolean`, `:map`, `:list`.
Field opts: `:required`, `:description`, `:default`.

## Callbacks

```elixir
@callback run(params :: map(), context :: map()) ::
  {:ok, map()} | {:ok, map(), [Command.t()]} | {:error, term()}

# Optional
@callback before_validate(params()) :: params()   # transform before validation
@callback after_run(map(), context()) :: map()     # transform after success
```

INCORRECT:

```elixir
def run(%{path: path}, _), do: File.read!(path)  # must return {:ok, map()}
```

CORRECT:

```elixir
def run(%{path: path}, _), do: {:ok, %{content: File.read!(path)}}
```

## Calling Actions

```elixir
# Direct (outside agent)
{:ok, result} = ReadFile.call(%{path: "/tmp/x"})

# From TEA agent (see SKILL.md for result message formats)
run_action(ReadFile, %{path: "/tmp/x"})        # sync, blocks update/2
run_action_async(ReadFile, %{path: "/tmp/x"})   # async command
run_pipeline_async([Step1, Step2], params)       # sequential pipeline
```

## Pipelines

Each step's output merges into shared state. Stops on first error.

```elixir
{:ok, result, commands} = Raxol.Agent.Action.Pipeline.run(
  [FetchData, ProcessData, SaveResult], initial_params, context
)
# Error: {:error, {FailedStepModule, reason}}
```

## LLM Tool Conversion

Actions auto-generate JSON Schema for LLM tool use:

```elixir
alias Raxol.Agent.Action.ToolConverter

tools = ToolConverter.to_tool_definitions([ReadFile, WriteFile])
{:ok, result} = ToolConverter.dispatch_tool_call(llm_tool_call, actions, ctx)
formatted = ToolConverter.format_tool_result(tool_call, result)
```

Process agents expose actions via `available_actions/0`. When a Strategy
(e.g., `Strategy.ReAct`) is configured, returning `{:act, {ActionModule, params}, state}`
from `think/2` runs the LLM tool loop automatically.
