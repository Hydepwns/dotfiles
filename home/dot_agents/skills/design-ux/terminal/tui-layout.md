---
title: Terminal UI Layout
impact: HIGH
impactDescription: Terminal constraints are absolute; violations crash or corrupt display
tags: tui, terminal, layout, grid, box-drawing, constraints, overflow
---

# Terminal UI Layout

## Character Grid Fundamentals

Everything is columns x rows. 1 character = 1 unit. Layout is integer arithmetic. There are no subpixel positions, no fractional widths.

INCORRECT:

```go
// Thinking in pixels for TUI layout
panel := NewPanel()
panel.SetWidth(250)   // 250 what? pixels don't exist here
panel.SetHeight(400)
panel.SetMargin(8.5)  // fractional values are meaningless
```

CORRECT:

```go
// Character grid: integer columns and rows
panel := NewPanel()
panel.SetWidth(40)    // 40 columns of text
panel.SetHeight(20)   // 20 rows
panel.SetMargin(1)    // 1 character of padding on each side
```

## Box-Drawing Characters

Use Unicode box-drawing characters, not ASCII approximations. Choose the weight that matches the UI context.

INCORRECT:

```
+--------+--------+
| Header | Status |
+--------+--------+
| Content         |
|                 |
+-----------------+
```

CORRECT:

```
Single line (default for content borders):
┌────────┬────────┐
│ Header │ Status │
├────────┼────────┤
│ Content         │
│                 │
└─────────────────┘

Rounded corners (softer feel, panels and cards):
╭────────┬────────╮
│ Header │ Status │
├────────┼────────┤
│ Content         │
│                 │
╰─────────────────╯

Double line (emphasis, outer frame, modal borders):
╔════════╦════════╗
║ Header ║ Status ║
╠════════╬════════╣
║ Content         ║
║                 ║
╚═════════════════╝

Heavy line (active/focused panels):
┏━━━━━━━━┳━━━━━━━━┓
┃ Header ┃ Status ┃
┣━━━━━━━━╋━━━━━━━━┫
┃ Content         ┃
┃                 ┃
┗━━━━━━━━━━━━━━━━━┛
```

Use single line as default. Rounded for cards/dialogs. Double for modal frames. Heavy for focused/active panels.

## Constraint-Based Sizing

Panels must reflow on terminal resize. Never hardcode widths that exceed minimum terminal dimensions.

INCORRECT:

```python
# Fixed width: breaks on terminals < 120 columns
class Layout:
    sidebar_width = 40
    main_width = 80
    # total: 120 -- unusable on 80-column terminals
```

CORRECT:

```python
# Constraint-based: adapts to available space
class Layout:
    sidebar_min = 20
    sidebar_max = 40
    sidebar_ratio = 0.3  # 30% of terminal width

    def sidebar_width(self, term_cols: int) -> int:
        target = int(term_cols * self.sidebar_ratio)
        return max(self.sidebar_min, min(self.sidebar_max, target))

    def main_width(self, term_cols: int) -> int:
        return term_cols - self.sidebar_width(term_cols) - 1  # -1 for border
```

## Overflow Handling

Content that exceeds its container must be truncated or scrolled. Never let it wrap mid-word or run off-screen.

INCORRECT:

```
╭──────────────╮
│ This is a ver│
│y long line th│    <- word broken mid-character, unreadable
│at wraps badly│
╰──────────────╯
```

CORRECT:

```
Truncation with ellipsis (for single-line fields):
╭──────────────╮
│ This is a v… │
╰──────────────╯

Word-aware wrapping (for multi-line content):
╭──────────────╮
│ This is a    │
│ very long    │
│ line that    │
│ wraps well   │
╰──────────────╯

Scrollable region (for unbounded content):
╭──────────────╮
│ Line 1       │
│ Line 2       │
│ Line 3       ▓    <- scroll indicator
│ Line 4       ░
╰──────────────╯
```

## Panel Layout Patterns

Common TUI layouts and when to use them.

```
Master-Detail (list + preview):
┌──────────┬─────────────────────┐
│ Items    │ Detail View         │
│ > Item 1 │                     │
│   Item 2 │ Name: Item 1        │
│   Item 3 │ Status: Active      │
│   Item 4 │ Created: 2026-04-08 │
│          │                     │
└──────────┴─────────────────────┘

Header + Body + Footer (dashboard):
┌─────────────────────────────────┐
│ App Name              v1.2.3   │
├─────────────────────────────────┤
│                                 │
│  Main content area              │
│                                 │
├─────────────────────────────────┤
│ Status: OK │ CPU: 12% │ Mem: 4G│
└─────────────────────────────────┘

Tab Layout (multi-view):
┌─[Overview]──[Logs]──[Config]────┐
│                                  │
│  Active tab content              │
│                                  │
└──────────────────────────────────┘

Split Panes (editor-style):
┌────────────────┬─────────────────┐
│ Left pane      │ Right pane      │
│                │                 │
│                │                 │
├────────────────┴─────────────────┤
│ Bottom pane                      │
└──────────────────────────────────┘
```

## Alignment and Padding

Content within panels needs consistent internal padding. Use 1-character padding as the minimum.

INCORRECT:

```
┌──────────────┐
│Status: OK    │    <- no padding, text touches border
│CPU: 45%      │
│Memory: 2.1GB │
└──────────────┘
```

CORRECT:

```
┌────────────────┐
│ Status: OK     │    <- 1ch padding on each side
│ CPU:    45%    │    <- aligned columns
│ Memory: 2.1GB │
└────────────────┘
```

For data-dense displays, align values in columns using fixed-width fields:

```
╭──────────────────────────────╮
│ Service      Status   Uptime │
│ ─────────────────────────── │
│ api          UP       14d 2h │
│ worker       UP        3d 8h │
│ scheduler    DOWN      0d 0h │
│ cache        UP       14d 2h │
╰──────────────────────────────╯
```
