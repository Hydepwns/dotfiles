---
title: AI Backends
impact: HIGH
tags: [raxol, agent, ai, backend, llm]
---

# AI Backends

Pluggable AI model integration via the `Raxol.Agent.AIBackend` behaviour.

## Behaviour

```elixir
@callback complete([%{role: :system | :user | :assistant, content: String.t()}], keyword()) ::
  {:ok, %{content: String.t(), usage: map(), metadata: map()}} | {:error, term()}

@callback stream([message], keyword()) ::
  {:ok, Enumerable.t()} | {:error, term()}  # optional

@callback available?() :: boolean()
@callback name() :: String.t()
@callback capabilities() :: [:completion | :streaming | :tool_use | :vision]
```

Stream events: `{:chunk, text}`, `{:done, response}`, `{:error, reason}`.

## Backend.HTTP

Supports Anthropic, OpenAI, Ollama, Kimi, Groq. Key opts:
`:provider`, `:api_key`, `:base_url`, `:model`, `:max_tokens`, `:timeout`.

Provider auto-detection from env vars (checked in order):
Lumo -> Anthropic (`ANTHROPIC_API_KEY`) -> Kimi -> OpenAI-compat (`AI_API_KEY`) -> Ollama (`OLLAMA_MODEL`) -> LLM7 (`FREE_AI=true`) -> Mock.

## Backend.Mock (Testing)

```elixir
# Static
[response: "Hello"]

# Dynamic
[response_fn: fn -> "dynamic" end]

# Error
[error: :rate_limited]

# Tool calls
[tool_calls: [%{"name" => "read_file", "arguments" => %{"path" => "/tmp/x"}}]]

# Latency
[response: "slow", latency_ms: 200]
```

Always use Mock in tests. See `testing/agent-testing.md`.

## Usage in Process Agents

```elixir
Process.start_link(
  agent_id: :my_agent,
  agent_module: MyAgent,
  backend: Raxol.Agent.Backend.HTTP,
  backend_config: [provider: :anthropic, api_key: key, model: "claude-opus-4-6-20250415"]
)
```

The backend is passed to Strategy modules which handle the LLM loop.
