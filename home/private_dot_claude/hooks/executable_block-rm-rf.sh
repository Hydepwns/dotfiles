#!/usr/bin/env bash
# Block recursive-force rm and suggest trash instead.
#
# Flags are attributed to the rm they actually belong to. An earlier version
# matched the bare string "rm" against the whole command, so it fired on any
# word ending in rm -- terraform, confirm, perform, form -- and scanned for
# -r/-f across unrelated commands, blocking things like "rm a.txt && grep -r -f".
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')
[[ -n "$command" ]] || exit 0

# Words that may precede the real command without changing what it is.
is_wrapper() {
    case "$1" in
        sudo | doas | env | time | command | builtin | exec) return 0 ;;
        nohup | nice | ionice | stdbuf) return 0 ;;
        *=*) return 0 ;; # VAR=value prefix
        *) return 1 ;;
    esac
}

# True when the segment runs rm with both a recursive and a force flag, or
# reaches rm through xargs -- there the file list is generated elsewhere, so the
# blast radius is not visible here.
segment_is_dangerous() {
    local seg="$1"
    local -a tok=()
    local i=0 n via_xargs=0 has_r=0 has_f=0 arg

    # Quotes are dropped so `bash -c "rm -rf /"` is inspected, not waved through.
    seg="${seg//\"/}"
    seg="${seg//\'/}"

    read -r -a tok <<<"$seg" || true
    n=${#tok[@]}

    while [[ $i -lt $n ]]; do
        if is_wrapper "${tok[i]}"; then
            i=$((i + 1))
        elif [[ ${tok[i]} == xargs ]]; then
            via_xargs=1
            i=$((i + 1))
            while [[ $i -lt $n && ${tok[i]} == -* ]]; do i=$((i + 1)); done
        elif [[ ${tok[i]} =~ ^(bash|sh|zsh|dash|ksh)$ ]]; then
            i=$((i + 1))
            if [[ $i -lt $n && ${tok[i]} == -c ]]; then i=$((i + 1)); fi
        else
            break
        fi
    done

    [[ $i -lt $n ]] || return 1
    # Strip any leading path so /bin/rm is still rm.
    [[ ${tok[i]##*/} == rm ]] || return 1
    i=$((i + 1))

    [[ $via_xargs -eq 1 ]] && return 0

    for ((; i < n; i++)); do
        arg="${tok[i]}"
        # Everything after -- is a filename, even if it is shaped like a flag.
        [[ $arg == -- ]] && break
        case "$arg" in
            --recursive) has_r=1 ;;
            --force) has_f=1 ;;
            --*) ;;
            -*)
                if [[ $arg == *[rR]* ]]; then has_r=1; fi
                if [[ $arg == *f* ]]; then has_f=1; fi
                ;;
        esac
    done

    [[ $has_r -eq 1 && $has_f -eq 1 ]]
}

# Split on shell separators so each segment holds at most one command.
separators=';&|(){}`'
while IFS= read -r segment; do
    [[ -n "${segment//[[:space:]]/}" ]] || continue
    if segment_is_dangerous "$segment"; then
        printf 'Blocked: %s\n' "${segment#"${segment%%[![:space:]]*}"}" >&2
        printf "rm -rf is destructive. Use 'trash' instead (brew install macos-trash).\n" >&2
        exit 2
    fi
done < <(printf '%s\n' "$command" | tr "$separators" '\n')

exit 0
