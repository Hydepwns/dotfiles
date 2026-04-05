---
title: Shell Script Patterns
impact: HIGH
impactDescription: safe, portable, shellcheck-clean scripts
tags: shell, bash, shellcheck, traps, getopts, quoting
---

# Shell Script Patterns

## Strict Mode and Trap Cleanup

Every script starts with `set -euo pipefail`. Use `trap` for cleanup on exit -- never rely on reaching the end of the script.

### Incorrect

```bash
#!/bin/bash

TMPDIR=$(mktemp -d)

# No set -e: failures silently continue
# No trap: temp dir leaks on error
curl -o "$TMPDIR/data.tar.gz" "$DOWNLOAD_URL"
tar xzf "$TMPDIR/data.tar.gz" -C /opt/app
rm -rf "$TMPDIR"
```

### Correct

```bash
#!/bin/bash
set -euo pipefail

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

curl -o "$WORK_DIR/data.tar.gz" "$DOWNLOAD_URL"
tar xzf "$WORK_DIR/data.tar.gz" -C /opt/app
# WORK_DIR cleaned up automatically on exit, error, or signal
```

## Conditionals and Quoting

Use `[[ ]]` over `[ ]`. Always quote variables. Use `"$@"` to forward arguments.

### Incorrect

```bash
# [ ] has word splitting issues, unquoted vars break on spaces
if [ $status = running ]; then
    echo "Service is up"
fi

# Unquoted variable with spaces causes multiple arguments
config_path=/etc/my app/config.toml
if [ -f $config_path ]; then
    cat $config_path
fi

# $* merges all args into one string, breaking arg boundaries
run_command() {
    echo "Running: $*"
    "$*"  # Tries to execute "arg1 arg2 arg3" as single command
}
```

### Correct

```bash
# [[ ]] handles empty strings, spaces, and pattern matching safely
if [[ "$status" = "running" ]]; then
    printf "Service is up\n"
fi

config_path="/etc/my app/config.toml"
if [[ -f "$config_path" ]]; then
    cat "$config_path"
fi

# "$@" preserves each argument as a separate word
run_command() {
    printf "Running: %s\n" "$*"
    "$@"
}
```

## printf Over echo, command -v Over which

Use `printf` for reliable output. Use `command -v` to check for executables.

### Incorrect

```bash
# echo behavior varies across shells (-n, -e, backslashes)
echo -e "Checking for dependencies...\n"

# which is not POSIX, may be aliased, prints paths we don't need
if which docker > /dev/null 2>&1; then
    echo "Docker version: $(docker --version)"
else
    echo "ERROR: Docker not found" >&2
    exit 1
fi
```

### Correct

```bash
printf "Checking for dependencies...\n\n"

if command -v docker &>/dev/null; then
    printf "Docker version: %s\n" "$(docker --version)"
else
    printf "ERROR: Docker not found\n" >&2
    exit 1
fi
```

## Guarding Non-Zero Exits

Under `set -e`, commands that legitimately return non-zero will abort the script. Guard them explicitly.

### Incorrect

```bash
set -euo pipefail

# grep returns 1 when no match -- script aborts unexpectedly
count=$(grep -c "ERROR" /var/log/app.log)
printf "Found %d errors\n" "$count"

# ((expr)) returns 1 when result is 0 -- script aborts
total=5
remaining=5
((used = total - remaining))  # used=0, exit code 1, script dies
printf "Used: %d\n" "$used"
```

### Correct

```bash
set -euo pipefail

# Guard grep with || true so zero matches don't abort
count=$(grep -c "ERROR" /var/log/app.log || true)
printf "Found %d errors\n" "$count"

# Use $(( )) assignment instead of (( )) -- always exit code 0
total=5
remaining=5
used=$((total - remaining))
printf "Used: %d\n" "$used"
```
