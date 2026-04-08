---
title: Terminal Aesthetic
impact: MEDIUM
impactDescription: Aesthetic consistency sets the tone but is not functionally critical
tags: terminal, monospace, ascii, density, aesthetic, droo, ansi
---

# Terminal Aesthetic

## Information Density

Terminal UIs should be dense but scannable. Every character of screen real estate earns its place. Do not port web-app spacing to the terminal.

INCORRECT:

```
╭──────────────────────────────────────╮
│                                      │
│                                      │
│        Welcome to Dashboard          │
│                                      │
│                                      │
│   ╭────────────────────────────╮     │
│   │                            │     │
│   │    Status: Running         │     │
│   │                            │     │
│   ╰────────────────────────────╯     │
│                                      │
│                                      │
╰──────────────────────────────────────╯
```

CORRECT:

```
╭─ Dashboard ──────────────────────────╮
│ Status: Running    CPU: 12%  Mem: 4G │
│ Uptime: 14d 2h     Load: 0.42       │
├──────────────────────────────────────┤
│ Recent Events                        │
│  04-08 09:12  Deploy v1.2.3 [OK]     │
│  04-08 09:01  Health check   [OK]    │
│  04-08 08:45  Config reload  [OK]    │
╰──────────────────────────────────────╯
```

## Status Indicators

Use ASCII/Unicode indicators with consistent semantics. Prefer text symbols over emoji.

INCORRECT:

```
🟢 Service A - Running
🔴 Service B - Down
🟡 Service C - Degraded
✅ Task 1 - Complete
❌ Task 2 - Failed
```

CORRECT:

```
Checkboxes (task/todo state):
  [x] Task complete
  [ ] Task pending
  [~] Task in progress
  [!] Task failed
  [-] Task skipped

Bullets (status indicators):
  * Active/running
  - Inactive/stopped
  ! Error/alert
  ~ Degraded/warning
  ? Unknown

Inline markers (compact lists):
  api         [OK]     14d 2h
  worker      [OK]      3d 8h
  scheduler   [FAIL]    0d 0h
  cache       [WARN]   14d 2h

Progress:
  [=========>          ] 47%
  [####################] 100%
  [--------------------]   0%
```

## ANSI Color Discipline

Use the base 16 ANSI colors for maximum terminal compatibility. Extended 256/truecolor only for data visualization where the base palette is insufficient.

INCORRECT:

```python
# Using 256-color/truecolor for basic UI elements
print(f"\033[38;2;147;51;234m{title}\033[0m")      # arbitrary purple
print(f"\033[38;2;236;72;153m{subtitle}\033[0m")    # arbitrary pink
print(f"\033[38;5;208m{warning}\033[0m")             # 256-color orange
# Breaks on terminals without truecolor support
```

CORRECT:

```python
# Base 16 ANSI for UI elements -- works everywhere
RESET = "\033[0m"
BOLD  = "\033[1m"
DIM   = "\033[2m"

RED     = "\033[31m"
GREEN   = "\033[32m"
YELLOW  = "\033[33m"
BLUE    = "\033[34m"
MAGENTA = "\033[35m"
CYAN    = "\033[36m"
WHITE   = "\033[37m"

# Semantic mapping
ERROR   = RED
SUCCESS = GREEN
WARNING = YELLOW
ACCENT  = MAGENTA   # DROO: magenta is the primary accent
INFO    = CYAN      # DROO: cyan is the secondary accent
MUTED   = DIM

print(f"{BOLD}{WHITE}{title}{RESET}")
print(f"{MUTED}{subtitle}{RESET}")
print(f"{ERROR}[FAIL]{RESET} {service_name}")
print(f"{SUCCESS}[OK]{RESET}   {service_name}")
```

## DROO Palette Mapped to ANSI

```
ANSI Color    DROO Mapping        Usage
──────────    ──────────────────  ──────────────────
Black         bg / surface        Background
Red           error / critical    Errors, failures
Green         success / healthy   Success, confirmations
Yellow        warning / caution   Warnings, pending
Blue          info / neutral      Informational
Magenta       accent / primary    Primary actions, highlights
Cyan          secondary / link    Secondary accent, links
White         foreground / text   Primary text

Bright Black  muted / disabled    Disabled, borders
Bright Red    error emphasis      Error headings
Bright Green  success emphasis    Success headings
Bright Yellow warning emphasis    Warning headings
Bright Blue   info emphasis       Info headings
Bright Mag.   accent emphasis     Active/focused
Bright Cyan   secondary emphasis  Highlighted links
Bright White  emphasis / bold     Headings, strong text
```

## Progressive Disclosure

Show summary first. Let users drill down. Do not render all data at once.

INCORRECT:

```
Showing all 847 log entries on one screen with full details:
  2026-04-08 09:12:33.456 [INFO] api.server.handler GET /api/v1/users ...
  2026-04-08 09:12:33.401 [DEBUG] db.pool.connection acquired conn_id=42 ...
  2026-04-08 09:12:33.399 [TRACE] net.tcp.read bytes=1024 fd=17 ...
  ... (844 more lines)
```

CORRECT:

```
Summary view (default):
  ╭─ Logs ─────────────────────────────╮
  │ 09:12  INFO   42 entries           │
  │ 09:11  WARN    3 entries           │
  │ 09:10  ERROR   1 entry    <──────── │
  │ 09:09  INFO   38 entries           │
  ╰────────────────────────────────────╯

Detail view (on select/enter):
  ╭─ 09:10 ERROR ──────────────────────╮
  │ db.pool.connection timeout         │
  │                                    │
  │ conn_id: 42                        │
  │ wait_ms: 5003                      │
  │ pool_size: 10/10                   │
  │ queue_depth: 23                    │
  │                                    │
  │ [q] Back  [j/k] Navigate  [/] Find│
  ╰────────────────────────────────────╯
```

## Keyboard Shortcuts Display

Show available keys in a footer bar or contextual hint. Follow vim/less conventions where applicable.

```
Footer bar pattern:
╭─────────────────────────────────────╮
│ ... content ...                     │
├─────────────────────────────────────┤
│ [q]uit [j/k]nav [/]find [?]help    │
╰─────────────────────────────────────╯

Contextual hint (appears on hover/focus):
  > Item selected ── [enter] open  [d] delete  [e] edit
```

## Spinners and Loading

Use simple character-cycling spinners. Avoid complex unicode animations that flicker on slow terminals.

```
Simple spinners (cycle through characters):
  Braille:  ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
  Pipe:     | / - \
  Dots:     .  ..  ...  (clear and repeat)
  Block:    ░ ▒ ▓ █ ▓ ▒

Usage:
  ⠹ Loading configuration...
  ⠸ Connecting to database...
  ✓ Connected (replace spinner with result)
```
