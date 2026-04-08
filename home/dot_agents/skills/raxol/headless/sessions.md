---
title: Headless Sessions
impact: HIGH
impactDescription: Headless mode is the primary interface for AI-driven testing and MCP tool integration.
tags: raxol, headless, testing, mcp
---

# Headless Sessions

`Raxol.Headless` runs TEA apps in `:agent` environment -- no terminal, no IO.
Text screenshots, keystroke injection, and model inspection.

## API

```elixir
# Start from module or file path (compiles, finds first module with view/1)
{:ok, :demo} = Raxol.Headless.start(RaxolDemo, id: :demo)
{:ok, :demo} = Raxol.Headless.start("examples/demo.exs", id: :demo, width: 80, height: 24)
# Default: 120x40

{:ok, text} = Raxol.Headless.screenshot(:demo)           # plain text, no ANSI
:ok = Raxol.Headless.send_key(:demo, :tab)                # special key (atom)
:ok = Raxol.Headless.send_key(:demo, "q")                 # character (string)
:ok = Raxol.Headless.send_key(:demo, "c", ctrl: true)     # with modifier
{:ok, text} = Raxol.Headless.send_key_and_screenshot(:demo, :enter, wait_ms: 100)
{:ok, model} = Raxol.Headless.get_model(:demo)
:ok = Raxol.Headless.stop(:demo)
[:demo] = Raxol.Headless.list()
```

Special keys (atoms): `:tab`, `:enter`, `:escape`, `:backspace`, `:up`, `:down`,
`:left`, `:right`, `:home`, `:end`, `:page_up`, `:page_down`, `:delete`,
`:insert`, `:f1`..`:f12`. Modifiers: `ctrl: true`, `alt: true`, `shift: true`.

INCORRECT:

```elixir
Raxol.Headless.send_key(:demo, "tab")  # wrong: 3-char string, not Tab key
```

CORRECT:

```elixir
Raxol.Headless.send_key(:demo, :tab)   # atom for special keys
```

## MCP Tools (Dev)

When `mix phx.server` is running, six tools are auto-injected into Tidewave
at `localhost:4000/tidewave/mcp`. Server must be running before starting
Claude Code.

| Tool | Inputs | Returns |
|------|--------|---------|
| `raxol_start` | module OR path, id?, width?, height? | session id |
| `raxol_screenshot` | id | plain text screen |
| `raxol_send_key` | id, key, ctrl?, alt?, shift?, wait_ms? | updated screen |
| `raxol_get_model` | id | inspected model |
| `raxol_stop` | id | confirmation |
| `raxol_list` | (none) | active session ids |

Typical workflow: start -> screenshot -> send keys -> screenshot -> get model -> stop.

Manual injection: `Raxol.Headless.McpTools.inject_into_tidewave()`.
