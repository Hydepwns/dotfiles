---
name: raxol
description: >
  Raxol terminal framework for TUI apps and AI agents in Elixir.
  TRIGGER when: code imports Raxol modules (Raxol.Agent, Raxol.Headless, Raxol.Core),
  mix.exs lists :raxol or :raxol_agent as dependency, user asks about building
  TUI apps or AI agents with Raxol, or working with Raxol headless/MCP tools.
  DO NOT TRIGGER when: general Elixir patterns (use droo-stack skill),
  Claude API / Anthropic SDK usage (use claude-api skill),
  or other TUI frameworks (Scenic, Termbox, etc.).
metadata:
  author: droo
  version: "1.0.0"
  tags: elixir, raxol, tui, agents, mcp, headless, orchestration
---

# Raxol Skill

Elixir TEA framework for terminal UIs + AI agent orchestration. Same codebase
runs in terminal, browser (LiveView), and SSH. OTP provides supervision, crash
isolation, and hot reload. Package split: `:raxol` (core TUI) and
`:raxol_agent` (agent framework).

## Two Agent Models

| | TEA Agent (`use Raxol.Agent`) | Process Agent (`use Raxol.Agent.UseProcess`) |
|---|---|---|
| Loop | Message-driven (`update/2`) | Tick-driven (observe/think/act) |
| Rendering | Optional `view/1` | Headless only |
| Input | Messages from agents, commands, MCP | Events buffer, directives |
| Best for | Agents with UI, reactive workflows | Autonomous background agents |
| Crash recovery | OTP restart, fresh `init/1` | `context_snapshot` + `restore_context` |
| AI backend | Manual (call in async commands) | Built-in via Strategy |

## See also

- `droo-stack` -- for general Elixir patterns (pipes, pattern matching, ExUnit)
- `design-ux` -- for TUI design principles (terminal layout, box-drawing, density)
- `claude-api` -- for Anthropic SDK integration in Elixir

## Reading Guide

| Task | File |
|------|------|
| Build a TEA agent + messaging | `agents/tea-agent.md` |
| Build an autonomous agent | `agents/process-agent.md` |
| Reusable actions / LLM tools | `agents/actions-pipelines.md` |
| Multi-agent teams / cockpit | `agents/teams-orchestrator.md` |
| AI backend integration | `ai/backends.md` |
| Consume external MCP servers | `ai/mcp-client.md` |
| Headless sessions + MCP tools | `headless/sessions.md` |
| Testing agents and actions | `testing/agent-testing.md` |

## Message Protocol

All TEA agents receive these in `update/2`. Defined once here, referenced
from other files.

```elixir
# Async message from another agent
{:agent_message, from_id, payload}

# Sync call -- MUST reply with send(pid, {:agent_reply, ref, reply})
{:call, caller_pid, ref, message}

# Team broadcast
{:team_broadcast, team_id, payload}

# Async command results
{:command_result, result}
{:command_result, {:shell_result, %{output: string, exit_status: int}}}
{:command_result, {:action_result, module, result_map}}
{:command_result, {:action_error, module, reason}}
{:command_result, {:pipeline_result, result_map}}
{:command_result, {:pipeline_error, step_module, reason}}
```

## Key Conventions

- All agents auto-register in `Raxol.Agent.Registry` by `:id`
- Always return `{model, command}` from `update/2`, never bare `model`
- `view/1` returning `nil` = headless (no rendering overhead)
- Agent package: `packages/raxol_agent/`
- Session agents register as `agent_id`, Process agents as `{:process, agent_id}`, MCP clients as `{:mcp_client, name}`

## Common Pitfalls

1. **Wrong update/2 return** -- must return `{model, Command.none()}` not bare `model`
2. **Forgetting call reply** -- `{:call, pid, ref, msg}` requires `send(pid, {:agent_reply, ref, reply})`; caller blocks with timeout
3. **Mixing agent models** -- TEA callbacks and ProcessBehaviour callbacks are separate behaviours
4. **Sync call deadlocks** -- Agent A calls B, B calls A = deadlock. Break cycles with async `send_agent/2`
5. **String vs atom keys** -- Headless `send_key` uses atoms for special keys (`:tab`), strings for characters (`"q"`)
6. **Real backends in tests** -- always use `Backend.Mock`, never HTTP

## Design Context

Raxol treats each rendering surface (terminal, web, SSH, MCP) as a functor
from the TEA model. Same `update/2`, same model, different projections.
MCP is being developed as a first-class rendering target (Phases 8-11) where
widgets auto-export tools via a `ToolProvider` behaviour. When building
features, consider how they would surface as MCP tools.
