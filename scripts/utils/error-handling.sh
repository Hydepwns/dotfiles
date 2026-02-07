#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2064,SC2155
# SC2034: Variables may be used by sourcing scripts
# SC2064: Trap expansion is intentional for current values
# SC2155: Combined declaration/assignment is acceptable here

# Error-handling.sh - Independent error handling utilities
# Standalone utility - source directly where needed

# Advanced error handling framework with retry mechanisms and circuit breakers
# Provides robust error handling, automatic retries, and graceful degradation

# Source shared utilities

# Error handling configuration
RETRY_MAX_ATTEMPTS="${ERROR_RETRY_MAX_ATTEMPTS:-3}"
RETRY_DELAY_BASE="${ERROR_RETRY_DELAY_BASE:-1}"
RETRY_DELAY_MAX="${ERROR_RETRY_DELAY_MAX:-60}"
CIRCUIT_BREAKER_THRESHOLD="${ERROR_CIRCUIT_BREAKER_THRESHOLD:-5}"
CIRCUIT_BREAKER_TIMEOUT="${ERROR_CIRCUIT_BREAKER_TIMEOUT:-300}"

# Error tracking
declare -A ERROR_COUNTS
declare -A CIRCUIT_BREAKERS
declare -A LAST_ERROR_TIME

# Colors for error output
if [[ -t 2 ]]; then
    ERROR_RED='\033[0;31m'
    ERROR_YELLOW='\033[1;33m'
    ERROR_GREEN='\033[0;32m'
    ERROR_BLUE='\033[0;34m'
    ERROR_RESET='\033[0m'
else
    ERROR_RED='' ERROR_YELLOW='' ERROR_GREEN='' ERROR_BLUE='' ERROR_RESET=''
fi

# Enhanced error logging
log_error_with_context() {
    local message="$1"
    local error_code="${2:-1}"
    local function_name="${3:-${FUNCNAME[1]}}"
    local line_number="${4:-${BASH_LINENO[0]}}"
    local stack_trace="${5:-}"

    # Create error context
    local timestamp
    timestamp=$(date -Iseconds)

    echo -e "${ERROR_RED}[ERROR]${ERROR_RESET} $timestamp [$function_name:$line_number] $message" >&2

    if [[ -n "$stack_trace" ]]; then
        echo -e "${ERROR_YELLOW}Stack trace:${ERROR_RESET}" >&2
        echo "$stack_trace" >&2
    fi

    # Log to error file if configured
    if [[ -n "${ERROR_LOG_FILE:-}" ]]; then
        echo "[$timestamp] ERROR [$function_name:$line_number] code=$error_code message=\"$message\"" >> "$ERROR_LOG_FILE"
    fi

    # Update error counts
    local error_key="${function_name}:${line_number}"
    ERROR_COUNTS["$error_key"]=$((${ERROR_COUNTS["$error_key"]:-0} + 1))
    LAST_ERROR_TIME["$error_key"]=$(date +%s)
}

# Generate stack trace
generate_stack_trace() {
    local stack=""
    local i=1

    while [[ $i -lt ${#BASH_LINENO[@]} ]]; do
        local func="${FUNCNAME[$i]}"
        local line="${BASH_LINENO[$((i-1))]}"
        local file="${BASH_SOURCE[$i]}"

        stack="$stack    at $func() ($file:$line)"$'\n'
        ((i++))
    done

    echo "$stack"
}

# Retry with exponential backoff
retry_with_backoff() {
    local command="$1"
    local max_attempts="${2:-$RETRY_MAX_ATTEMPTS}"
    local delay_base="${3:-$RETRY_DELAY_BASE}"
    local delay_max="${4:-$RETRY_DELAY_MAX}"
    local description="${5:-command}"

    local attempt=1
    local delay="$delay_base"

    while [[ $attempt -le $max_attempts ]]; do
        echo -e "${ERROR_BLUE}[RETRY]${ERROR_RESET} Attempt $attempt/$max_attempts: $description" >&2

        if eval "$command"; then
            if [[ $attempt -gt 1 ]]; then
                echo -e "${ERROR_GREEN}[SUCCESS]${ERROR_RESET} Command succeeded on attempt $attempt" >&2
            fi
            return 0
        fi

        local exit_code=$?

        if [[ $attempt -eq $max_attempts ]]; then
            log_error_with_context "Command failed after $max_attempts attempts: $description" "$exit_code"
            return $exit_code
        fi

        echo -e "${ERROR_YELLOW}[BACKOFF]${ERROR_RESET} Waiting ${delay}s before retry..." >&2
        sleep "$delay"

        # Exponential backoff with jitter
        delay=$(( delay * 2 ))
        if [[ $delay -gt $delay_max ]]; then
            delay=$delay_max
        fi

        # Add random jitter (±25%)
        local jitter=$((delay / 4))
        local random_jitter=$(( (RANDOM % (jitter * 2)) - jitter ))
        delay=$((delay + random_jitter))

        ((attempt++))
    done

    return $EXIT_FAILURE
}

# Circuit breaker pattern
circuit_breaker() {
    local circuit_name="$1"
    local command="$2"
    local threshold="${3:-$CIRCUIT_BREAKER_THRESHOLD}"
    local timeout="${4:-$CIRCUIT_BREAKER_TIMEOUT}"

    local current_time
    current_time=$(date +%s)

    # Check circuit state
    local circuit_state="${CIRCUIT_BREAKERS["$circuit_name"]:-closed}"
    local failure_count="${ERROR_COUNTS["$circuit_name"]:-0}"
    local last_failure_time="${LAST_ERROR_TIME["$circuit_name"]:-0}"

    case "$circuit_state" in
        "open")
            # Circuit is open, check if timeout has passed
            if [[ $((current_time - last_failure_time)) -gt $timeout ]]; then
                echo -e "${ERROR_YELLOW}[CIRCUIT]${ERROR_RESET} Circuit $circuit_name transitioning to half-open" >&2
                CIRCUIT_BREAKERS["$circuit_name"]="half-open"
            else
                echo -e "${ERROR_RED}[CIRCUIT]${ERROR_RESET} Circuit $circuit_name is open, failing fast" >&2
                return $EXIT_FAILURE
            fi
            ;;
        "half-open")
            echo -e "${ERROR_BLUE}[CIRCUIT]${ERROR_RESET} Circuit $circuit_name is half-open, testing..." >&2
            ;;
        *)
            # Circuit is closed, normal operation
            ;;
    esac

    # Execute command
    if eval "$command"; then
        # Success - reset circuit if it was half-open or open
        if [[ "$circuit_state" != "closed" ]]; then
            echo -e "${ERROR_GREEN}[CIRCUIT]${ERROR_RESET} Circuit $circuit_name closing after successful operation" >&2
            CIRCUIT_BREAKERS["$circuit_name"]="closed"
            ERROR_COUNTS["$circuit_name"]=0
        fi
        return 0
    else
        local exit_code=$?

        # Failure - update counts and potentially open circuit
        ERROR_COUNTS["$circuit_name"]=$((${ERROR_COUNTS["$circuit_name"]:-0} + 1))
        LAST_ERROR_TIME["$circuit_name"]=$current_time

        if [[ ${ERROR_COUNTS["$circuit_name"]} -ge $threshold ]]; then
            echo -e "${ERROR_RED}[CIRCUIT]${ERROR_RESET} Circuit $circuit_name opening due to failure threshold" >&2
            CIRCUIT_BREAKERS["$circuit_name"]="open"
        fi

        return $exit_code
    fi
}

# Timeout wrapper
with_timeout() {
    local timeout_seconds="$1"
    local command="$2"
    local description="${3:-command}"

    echo -e "${ERROR_BLUE}[TIMEOUT]${ERROR_RESET} Running with ${timeout_seconds}s timeout: $description" >&2

    # Use timeout command if available
    if command -v timeout >/dev/null 2>&1; then
        if timeout "$timeout_seconds" bash -c "$command"; then
            return 0
        else
            local exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                log_error_with_context "Command timed out after ${timeout_seconds}s: $description" "$exit_code"
            fi
            return $exit_code
        fi
    else
        # Fallback implementation using background process
        eval "$command" &
        local pid=$!
        local count=0

        while [[ $count -lt $timeout_seconds ]]; do
            if ! kill -0 "$pid" 2>/dev/null; then
                # Process has finished
                wait "$pid"
                return $?
            fi

            sleep 1
            ((count++))
        done

        # Timeout reached
        kill -TERM "$pid" 2>/dev/null
        sleep 1
        kill -KILL "$pid" 2>/dev/null

        log_error_with_context "Command timed out after ${timeout_seconds}s: $description" 124
        return 124
    fi
}

# Graceful degradation
graceful_degradation() {
    local primary_command="$1"
    local fallback_command="$2"
    local description="${3:-operation}"

    echo -e "${ERROR_BLUE}[GRACEFUL]${ERROR_RESET} Attempting primary: $description" >&2

    if eval "$primary_command"; then
        return 0
    fi

    local primary_exit_code=$?
    echo -e "${ERROR_YELLOW}[GRACEFUL]${ERROR_RESET} Primary failed, trying fallback: $description" >&2

    if eval "$fallback_command"; then
        echo -e "${ERROR_GREEN}[GRACEFUL]${ERROR_RESET} Fallback succeeded: $description" >&2
        return 0
    fi

    local fallback_exit_code=$?
    log_error_with_context "Both primary and fallback failed: $description" "$fallback_exit_code"
    return $fallback_exit_code
}

# Network operation with retry and circuit breaker
network_operation() {
    local url="$1"
    local method="${2:-GET}"
    local timeout="${3:-30}"
    local retries="${4:-3}"

    local circuit_name="network_$(echo "$url" | shasum | cut -c1-8)"
    local description="$method $url"

    circuit_breaker "$circuit_name" \
        "with_timeout $timeout 'retry_with_backoff \"curl -s -X $method --fail --max-time $timeout $url\" $retries 1 10 \"$description\"'" \
        3 300
}

# File operation with backup and recovery
safe_file_operation() {
    local operation="$1"
    local file_path="$2"
    local backup_suffix="${3:-.backup.$(date +%s)}"

    # Create backup if file exists
    if [[ -f "$file_path" ]]; then
        local backup_path="${file_path}${backup_suffix}"
        cp "$file_path" "$backup_path"
        echo -e "${ERROR_BLUE}[BACKUP]${ERROR_RESET} Created backup: $backup_path" >&2

        # Trap to restore backup on failure
        trap "echo -e '${ERROR_YELLOW}[RESTORE]${ERROR_RESET} Restoring backup due to error' >&2; mv '$backup_path' '$file_path'" ERR
    fi

    # Execute operation with error handling
    if eval "$operation"; then
        # Success - remove backup
        if [[ -f "$backup_path" ]]; then
            rm -f "$backup_path"
        fi
        trap - ERR
        return 0
    else
        local exit_code=$?
        # Error handling is done by the trap
        trap - ERR
        return $exit_code
    fi
}

# Process monitoring with automatic restart
monitor_process() {
    local command="$1"
    local max_restarts="${2:-3}"
    local restart_delay="${3:-5}"
    local description="${4:-process}"

    local restart_count=0
    local start_time
    start_time=$(date +%s)

    while [[ $restart_count -le $max_restarts ]]; do
        echo -e "${ERROR_BLUE}[MONITOR]${ERROR_RESET} Starting $description (attempt $((restart_count + 1)))" >&2

        if eval "$command"; then
            # Process completed successfully
            return 0
        fi

        local exit_code=$?
        local current_time
        current_time=$(date +%s)
        local runtime=$((current_time - start_time))

        # If process ran for less than restart_delay seconds, count as immediate failure
        if [[ $runtime -lt $restart_delay ]]; then
            ((restart_count++))
        else
            # Reset restart count for long-running processes
            restart_count=0
        fi

        if [[ $restart_count -gt $max_restarts ]]; then
            log_error_with_context "Process failed too many times: $description" "$exit_code"
            return $exit_code
        fi

        echo -e "${ERROR_YELLOW}[MONITOR]${ERROR_RESET} Process failed, restarting in ${restart_delay}s..." >&2
        sleep "$restart_delay"
        start_time=$(date +%s)
    done
}

# Error recovery strategies
error_recovery() {
    local error_type="$1"
    local context="$2"

    case "$error_type" in
        "network")
            echo -e "${ERROR_YELLOW}[RECOVERY]${ERROR_RESET} Network error detected, checking connectivity..." >&2
            if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
                echo -e "${ERROR_GREEN}[RECOVERY]${ERROR_RESET} Network is available, retrying operation" >&2
                return 0
            else
                echo -e "${ERROR_RED}[RECOVERY]${ERROR_RESET} Network is unavailable, cannot recover" >&2
                return 1
            fi
            ;;
        "permission")
            echo -e "${ERROR_YELLOW}[RECOVERY]${ERROR_RESET} Permission error detected" >&2
            if [[ $EUID -eq 0 ]]; then
                echo -e "${ERROR_RED}[RECOVERY]${ERROR_RESET} Already running as root, cannot escalate further" >&2
                return 1
            else
                echo -e "${ERROR_BLUE}[RECOVERY]${ERROR_RESET} Attempting to run with sudo" >&2
                return 0
            fi
            ;;
        "disk_space")
            echo -e "${ERROR_YELLOW}[RECOVERY]${ERROR_RESET} Disk space error detected, checking available space" >&2
            local available
            available=$(df . | tail -1 | awk '{print $4}')
            if [[ $available -gt 1048576 ]]; then  # More than 1GB available
                echo -e "${ERROR_GREEN}[RECOVERY]${ERROR_RESET} Sufficient space available, retrying" >&2
                return 0
            else
                echo -e "${ERROR_RED}[RECOVERY]${ERROR_RESET} Insufficient disk space ($available KB), cannot recover" >&2
                return 1
            fi
            ;;
        *)
            echo -e "${ERROR_YELLOW}[RECOVERY]${ERROR_RESET} Unknown error type: $error_type" >&2
            return 1
            ;;
    esac
}

# Enhanced trap handler
setup_enhanced_error_handling() {
    local script_name="${1:-$0}"
    local log_file="${2:-/dev/stderr}"

    # Set error handling options
    set -eE  # Exit on error and inherit traps
    set -o pipefail  # Exit on pipe failure

    # Enhanced error trap
    trap 'handle_error $? $LINENO "${BASH_COMMAND}" "${FUNCNAME[*]}" "${BASH_SOURCE[*]}"' ERR

    # Exit trap for cleanup
    trap 'cleanup_on_exit $?' EXIT

    # Signal traps
    trap 'handle_signal INT' INT
    trap 'handle_signal TERM' TERM
    trap 'handle_signal HUP' HUP
}

# Error handler function
handle_error() {
    local exit_code="$1"
    local line_number="$2"
    local command="$3"
    local function_stack="$4"
    local source_stack="$5"

    # Generate detailed error information
    local error_context="Command: $command"$'\n'
    error_context+="Exit Code: $exit_code"$'\n'
    error_context+="Line: $line_number"$'\n'
    error_context+="Function Stack: $function_stack"$'\n'
    error_context+="Source Stack: $source_stack"

    log_error_with_context "Script execution failed" "$exit_code" "${function_stack%% *}" "$line_number" "$error_context"

    # Attempt error recovery
    case "$exit_code" in
        1)
            error_recovery "network" "$command" || true
            ;;
        126|127)
            error_recovery "permission" "$command" || true
            ;;
        28)  # Disk full
            error_recovery "disk_space" "$command" || true
            ;;
    esac
}

# Signal handler
handle_signal() {
    local signal="$1"
    echo -e "${ERROR_YELLOW}[SIGNAL]${ERROR_RESET} Received signal: $signal" >&2

    case "$signal" in
        "INT"|"TERM")
            echo -e "${ERROR_YELLOW}[SIGNAL]${ERROR_RESET} Performing graceful shutdown..." >&2
            cleanup_on_exit 130
            exit 130
            ;;
        "HUP")
            echo -e "${ERROR_BLUE}[SIGNAL]${ERROR_RESET} Received HUP, reloading configuration..." >&2
            # Reload configuration if applicable
            ;;
    esac
}

# Cleanup handler
cleanup_on_exit() {
    local exit_code="$1"

    # Perform cleanup operations
    if [[ $exit_code -ne 0 ]]; then
        echo -e "${ERROR_YELLOW}[CLEANUP]${ERROR_RESET} Script exiting with error code: $exit_code" >&2
    fi

    # Clean up temporary files, processes, etc.
    # This would be customized per script
}

# Error statistics
print_error_statistics() {
    echo "Error Statistics:"
    echo "================"

    if [[ ${#ERROR_COUNTS[@]} -eq 0 ]]; then
        echo "No errors recorded"
        return
    fi

    for key in "${!ERROR_COUNTS[@]}"; do
        local count="${ERROR_COUNTS[$key]}"
        local last_time="${LAST_ERROR_TIME[$key]:-0}"
        local last_time_formatted

        if [[ $last_time -gt 0 ]]; then
            last_time_formatted=$(date -d "@$last_time" 2>/dev/null || date -r "$last_time" 2>/dev/null || echo "unknown")
        else
            last_time_formatted="never"
        fi

        echo "  $key: $count errors, last: $last_time_formatted"
    done

    echo ""
    echo "Circuit Breaker Status:"
    echo "======================"

    if [[ ${#CIRCUIT_BREAKERS[@]} -eq 0 ]]; then
        echo "No circuit breakers active"
        return
    fi

    for circuit in "${!CIRCUIT_BREAKERS[@]}"; do
        local state="${CIRCUIT_BREAKERS[$circuit]}"
        local failures="${ERROR_COUNTS[$circuit]:-0}"

        echo "  $circuit: $state ($failures failures)"
    done
}

# Export functions for use in other scripts
export -f log_error_with_context retry_with_backoff circuit_breaker
export -f with_timeout graceful_degradation network_operation
export -f safe_file_operation monitor_process error_recovery


# Setup error handling
setup_error_handling() {
    set -euo pipefail
    trap 'log_error_with_context "Script failed at line $LINENO" $?' ERR
}
