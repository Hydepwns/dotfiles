---
title: MCP Client
impact: MEDIUM
tags: [raxol, agent, mcp, client]
---

# MCP Client

`Raxol.Agent.McpClient` -- stdio-based MCP client for consuming external tool
servers. Handles initialization handshake, tool discovery, and execution.

```elixir
{:ok, client} = McpClient.start_link(
  name: :fs, command: "npx",
  args: ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
)

{:ok, tools} = McpClient.list_tools(client)
{:ok, result} = McpClient.call_tool(client, "read_file", %{"path" => "/tmp/x"})
# result: %{content: [%{"type" => "text", "text" => "..."}], is_error: false}

McpClient.stop(client)
```

Tool namespacing: `McpClient.tool_name(:fs, "read_file")` -> `"mcp__fs__read_file"`.
Parse back: `McpClient.parse_tool_name("mcp__fs__read_file")` -> `{:ok, {"fs", "read_file"}}`.

Protocol version: `2024-11-05`. Call timeout: 30s.
Registers in `Raxol.Agent.Registry` as `{:mcp_client, name}`.
