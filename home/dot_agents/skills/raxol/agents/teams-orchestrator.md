---
title: Teams and Orchestrator
impact: MEDIUM
impactDescription: Multi-agent coordination is optional and only needed for complex workflows.
tags: raxol, agent, team, orchestrator, cockpit
---

# Teams and Orchestrator

## Teams

`Raxol.Agent.Team` -- OTP Supervisor for coordinator + worker agents:

```elixir
{:ok, sup} = Raxol.Agent.Team.start_link(
  team_id: :review_team,
  coordinator: {ReviewCoordinator, [id: :coordinator]},
  workers: [
    {FileAnalyzer, [id: :w1]},
    {FileAnalyzer, [id: :w2]}
  ],
  strategy: :rest_for_one  # default; coordinator crash restarts all workers
)
```

Strategies: `:rest_for_one` (default), `:one_for_one`.
Each agent starts as a `Session` with `team_id` set.

## Orchestrator

`Raxol.Agent.Orchestrator` -- multi-pane cockpit for Process agents.

Pilot modes:
- `:observe` -- watch agents work (default)
- `:command` -- send directives to agents
- `:takeover` -- directly control focused agent's terminal

```elixir
{:ok, orch} = Orchestrator.start_link()

# Agent management
{:ok, id} = Orchestrator.spawn_agent(orch, :agent, AgentMod, label: "My Agent")
:ok = Orchestrator.kill_agent(orch, :agent)
:ok = Orchestrator.focus_pane(orch, :agent)

# Pilot control
:ok = Orchestrator.pilot_takeover(orch)
:ok = Orchestrator.pilot_release(orch)
:ok = Orchestrator.send_input(orch, input)  # during takeover only

# Directives
:ok = Orchestrator.send_directive(orch, :agent, directive)
:ok = Orchestrator.broadcast_directive(orch, directive)

# Status
layout = Orchestrator.get_layout(orch)   # %{panes:, focused:, pilot_mode:, agent_count:}
statuses = Orchestrator.get_statuses(orch)

# Subscribe to events: {:orchestrator_event, event}
:ok = Orchestrator.subscribe(orch)
```

When a Process agent returns `{:ask_pilot, question, state}` from `think/2`,
the Orchestrator receives `{:agent_query, agent_id, %Protocol{}}`.
