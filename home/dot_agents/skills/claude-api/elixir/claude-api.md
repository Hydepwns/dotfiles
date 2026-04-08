---
title: Claude API with Elixir via REST
impact: CRITICAL
impactDescription: Primary entry point for Elixir Claude API usage via Req HTTP client against the REST API directly.
tags: elixir, claude, api, rest, req, anthropic
---

# Claude API -- Elixir

> **Note:** There is no official Anthropic SDK for Elixir. These patterns use `Req` (the standard Elixir HTTP client) against the REST API directly. For tool-use concepts and prompt caching design, see `shared/tool-use-concepts.md` and `shared/prompt-caching.md`.

## Setup

Add `req` and `jason` to your `mix.exs` dependencies:

```elixir
defp deps do
  [
    {:req, "~> 0.5"},
    {:jason, "~> 1.4"}
  ]
end
```

---

## Client Module

Wrap the API in a module with a reusable client:

```elixir
defmodule Claude do
  @api_url "https://api.anthropic.com/v1/messages"

  def client do
    Req.new(
      base_url: "https://api.anthropic.com/v1",
      headers: [
        {"x-api-key", api_key()},
        {"anthropic-version", "2023-06-01"},
        {"content-type", "application/json"}
      ]
    )
  end

  defp api_key, do: System.fetch_env!("ANTHROPIC_API_KEY")
end
```

---

## Basic Message Request

```elixir
defmodule Claude do
  # ... client/0 from above

  def message(prompt, opts \\ []) do
    model = Keyword.get(opts, :model, "claude-opus-4-6")
    max_tokens = Keyword.get(opts, :max_tokens, 16_000)
    system = Keyword.get(opts, :system, nil)

    body =
      %{
        model: model,
        max_tokens: max_tokens,
        messages: [%{role: "user", content: prompt}]
      }
      |> then(fn body ->
        case system do
          nil -> body
          sys -> Map.put(body, :system, sys)
        end
      end)

    case Req.post(client(), url: "/messages", json: body) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def text(%{"content" => [%{"type" => "text", "text" => text} | _]}), do: text
  def text(%{"content" => content}) when is_list(content) do
    content
    |> Enum.filter(&(&1["type"] == "text"))
    |> Enum.map_join("\n", & &1["text"])
  end
end
```

Usage:

```elixir
{:ok, resp} = Claude.message("What is the capital of France?")
IO.puts(Claude.text(resp))
```

---

## Streaming (SSE)

Req supports streaming via `into:` with a collectable or function. The API sends Server-Sent Events when `"stream": true`.

```elixir
defmodule Claude.Stream do
  def stream(prompt, opts \\ []) do
    model = Keyword.get(opts, :model, "claude-opus-4-6")
    max_tokens = Keyword.get(opts, :max_tokens, 64_000)

    body = %{
      model: model,
      max_tokens: max_tokens,
      stream: true,
      messages: [%{role: "user", content: prompt}]
    }

    pid = self()

    Req.post(Claude.client(), url: "/messages", json: body,
      into: fn {:data, data}, {req, resp} ->
        data
        |> parse_sse()
        |> Enum.each(fn event -> send(pid, {:sse, event}) end)
        {:cont, {req, resp}}
      end
    )
  end

  defp parse_sse(chunk) do
    chunk
    |> String.split("\n")
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.flat_map(fn lines ->
      data_lines = Enum.filter(lines, &String.starts_with?(&1, "data: "))
      Enum.map(data_lines, fn "data: " <> json -> Jason.decode!(json) end)
    end)
  end
end
```

Accumulate text deltas:

```elixir
Claude.Stream.stream("Write a haiku")

Stream.repeatedly(fn ->
  receive do
    {:sse, %{"type" => "content_block_delta", "delta" => %{"text" => text}}} ->
      IO.write(text)
      :ok
    {:sse, %{"type" => "message_stop"}} ->
      :done
    {:sse, _} ->
      :ok
  end
end)
|> Enum.take_while(&(&1 != :done))
```

---

## Tool Use (Manual Agentic Loop)

Define tools as maps matching the JSON schema, execute them locally, loop until `stop_reason != "tool_use"`.

```elixir
defmodule Claude.Tools do
  @tools [
    %{
      name: "get_weather",
      description: "Get current weather for a city",
      input_schema: %{
        type: "object",
        properties: %{
          city: %{type: "string", description: "City name"}
        },
        required: ["city"]
      }
    }
  ]

  def run(prompt) do
    messages = [%{role: "user", content: prompt}]
    loop(messages)
  end

  defp loop(messages) do
    body = %{
      model: "claude-opus-4-6",
      max_tokens: 16_000,
      tools: @tools,
      messages: messages
    }

    {:ok, %{status: 200, body: resp}} =
      Req.post(Claude.client(), url: "/messages", json: body)

    # Append assistant response to history
    messages = messages ++ [%{role: "assistant", content: resp["content"]}]

    case resp["stop_reason"] do
      "tool_use" ->
        tool_results =
          resp["content"]
          |> Enum.filter(&(&1["type"] == "tool_use"))
          |> Enum.map(fn call ->
            result = execute_tool(call["name"], call["input"])
            %{type: "tool_result", tool_use_id: call["id"], content: result}
          end)

        messages = messages ++ [%{role: "user", content: tool_results}]
        loop(messages)

      _ ->
        resp
    end
  end

  defp execute_tool("get_weather", %{"city" => city}) do
    "The weather in #{city} is sunny, 72F"
  end
end
```

Usage:

```elixir
resp = Claude.Tools.run("What's the weather in Paris?")
IO.puts(Claude.text(resp))
```

---

## Thinking (Adaptive)

```elixir
body = %{
  model: "claude-opus-4-6",
  max_tokens: 16_000,
  thinking: %{type: "adaptive"},
  messages: [%{role: "user", content: "How many r's in strawberry?"}]
}

{:ok, %{status: 200, body: resp}} =
  Req.post(Claude.client(), url: "/messages", json: body)

for block <- resp["content"] do
  case block["type"] do
    "thinking" -> IO.puts("[thinking] #{block["thinking"]}")
    "text" -> IO.puts(block["text"])
    _ -> :ok
  end
end
```

Combine with effort:

```elixir
body = %{
  model: "claude-opus-4-6",
  max_tokens: 16_000,
  thinking: %{type: "adaptive"},
  output_config: %{effort: "max"},
  messages: [%{role: "user", content: "Prove the Riemann hypothesis"}]
}
```

---

## Prompt Caching

Place `cache_control` on the last block of your stable prefix. See `shared/prompt-caching.md` for placement patterns.

```elixir
body = %{
  model: "claude-opus-4-6",
  max_tokens: 16_000,
  system: [
    %{
      type: "text",
      text: large_system_prompt,
      cache_control: %{type: "ephemeral"}
    }
  ],
  messages: [%{role: "user", content: "Summarize the key points"}]
}

{:ok, %{status: 200, body: resp}} =
  Req.post(Claude.client(), url: "/messages", json: body)

# Verify cache hits
IO.inspect(resp["usage"]["cache_read_input_tokens"], label: "cache hits")
```

---

## Multi-turn Conversation

Maintain a message list across turns. Append full `content` arrays (not just text).

```elixir
defmodule Claude.Conversation do
  def new(system \\ nil) do
    %{messages: [], system: system}
  end

  def say(%{messages: messages, system: system} = conv, user_text) do
    messages = messages ++ [%{role: "user", content: user_text}]

    body =
      %{
        model: "claude-opus-4-6",
        max_tokens: 16_000,
        messages: messages
      }
      |> then(fn b ->
        case system do
          nil -> b
          s -> Map.put(b, :system, s)
        end
      end)

    {:ok, %{status: 200, body: resp}} =
      Req.post(Claude.client(), url: "/messages", json: body)

    # Preserve full content array for compaction compatibility
    messages = messages ++ [%{role: "assistant", content: resp["content"]}]
    {Claude.text(resp), %{conv | messages: messages}}
  end
end
```

---

## Error Handling

Match on HTTP status codes. See `shared/error-codes.md` for the full list.

```elixir
case Req.post(Claude.client(), url: "/messages", json: body) do
  {:ok, %{status: 200, body: body}} ->
    {:ok, body}

  {:ok, %{status: 429, body: body}} ->
    # Rate limited -- respect Retry-After header
    {:error, :rate_limited, body}

  {:ok, %{status: 529, body: body}} ->
    # Overloaded -- back off and retry
    {:error, :overloaded, body}

  {:ok, %{status: status, body: body}} when status >= 400 ->
    {:error, {status, body["error"]["message"]}}

  {:error, %Req.TransportError{reason: reason}} ->
    {:error, {:transport, reason}}
end
```

For production use, configure retries on Req:

```elixir
def client do
  Req.new(
    base_url: "https://api.anthropic.com/v1",
    headers: [
      {"x-api-key", api_key()},
      {"anthropic-version", "2023-06-01"}
    ],
    retry: :transient,
    max_retries: 3,
    retry_delay: &retry_delay/1
  )
end

defp retry_delay(attempt), do: Integer.pow(2, attempt) * 1_000
```
