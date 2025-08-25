#!/usr/bin/env bash

# Standard script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(cd "$SCRIPT_DIR" && find . .. ../.. -name "script-init.sh" -type f | head -1 | xargs dirname)"
source "$UTILS_DIR/script-init.sh"


# Dashboard Server Manager - Start/stop/manage the web dashboard
# Integrates with the existing dotfiles framework

# Source shared utilities
DOTFILES_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
UTILS_DIR="$SCRIPT_DIR"


setup_error_handling

# Configuration
DASHBOARD_DIR="$DOTFILES_ROOT/dashboard"
API_SCRIPT="$DASHBOARD_DIR/api/dashboard-api.sh"
DASHBOARD_PORT="${DASHBOARD_PORT:-8080}"
API_PORT="${API_PORT:-8081}"
PID_FILE="$DOTFILES_ROOT/.cache/dashboard.pid"
LOG_FILE="$DOTFILES_ROOT/.cache/dashboard.log"

# Ensure required directories exist
mkdir -p "$(dirname "$PID_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"

# Print status message
print_status() {
    local message="$1"
    local type="${2:-info}"
    
    case "$type" in
        "success")
            echo -e "${GREEN}[OK]${RESET} $message"
            ;;
        "error")
            echo -e "${RED}[FAIL]${RESET} $message"
            ;;
        "warning")
            echo -e "${YELLOW}⚠${RESET} $message"
            ;;
        *)
            echo -e "${BLUE}ℹ${RESET} $message"
            ;;
    esac
}

# Check if dashboard is running
is_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        else
            # PID file exists but process is dead
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# Get dashboard status
get_status() {
    if is_running; then
        local pid
        pid=$(cat "$PID_FILE")
        print_status "Dashboard is running (PID: $pid)" "success"
        print_status "Dashboard URL: http://localhost:$DASHBOARD_PORT" "info"
        print_status "API URL: http://localhost:$API_PORT" "info"
        return 0
    else
        print_status "Dashboard is not running" "warning"
        return 1
    fi
}

# Start the dashboard server
start_dashboard() {
    if is_running; then
        print_status "Dashboard is already running" "warning"
        get_status
        return 0
    fi
    
    print_status "Starting Dashboard Server..." "info"
    
    # Check if required files exist
    if [[ ! -f "$DASHBOARD_DIR/index.html" ]]; then
        print_status "Dashboard files not found in $DASHBOARD_DIR" "error"
        return $EXIT_FILE_NOT_FOUND
    fi
    
    # Start simple HTTP server for static files
    local server_started=false
    
    # Try Python HTTP server first
    if command -v python3 >/dev/null 2>&1; then
        print_status "Starting HTTP server with Python3..." "info"
        cd "$DASHBOARD_DIR" || exit $EXIT_FAILURE
        
        python3 -m http.server $DASHBOARD_PORT >/dev/null 2>&1 &
        local server_pid=$!
        
        # Wait a moment and check if server started
        sleep 2
        if kill -0 $server_pid 2>/dev/null; then
            echo $server_pid > "$PID_FILE"
            server_started=true
            print_status "Dashboard server started on port $DASHBOARD_PORT" "success"
        else
            print_status "Failed to start Python HTTP server" "error"
        fi
    fi
    
    # Fallback to other servers if Python failed
    if [[ "$server_started" != "true" ]] && command -v php >/dev/null 2>&1; then
        print_status "Starting HTTP server with PHP..." "info"
        cd "$DASHBOARD_DIR" || exit $EXIT_FAILURE
        
        php -S localhost:$DASHBOARD_PORT >/dev/null 2>&1 &
        local server_pid=$!
        
        sleep 2
        if kill -0 $server_pid 2>/dev/null; then
            echo $server_pid > "$PID_FILE"
            server_started=true
            print_status "Dashboard server started on port $DASHBOARD_PORT" "success"
        else
            print_status "Failed to start PHP server" "error"
        fi
    fi
    
    if [[ "$server_started" != "true" ]]; then
        print_status "No suitable HTTP server found (tried: python3, php)" "error"
        print_status "Please install Python 3 or PHP to run the dashboard" "error"
        return $EXIT_FAILURE
    fi
    
    # Start API server if available
    if [[ -f "$API_SCRIPT" ]] && [[ -x "$API_SCRIPT" ]]; then
        print_status "Starting Dashboard API on port $API_PORT..." "info"
        
        DASHBOARD_PORT="$API_PORT" "$API_SCRIPT" server >/dev/null 2>&1 &
        local api_pid=$!
        
        # Store both PIDs (simple approach - just overwrite with main server PID)
        echo $server_pid > "$PID_FILE"
        echo $api_pid >> "$PID_FILE.api"
        
        print_status "Dashboard API started" "success"
    fi
    
    # Open dashboard in browser if available
    local dashboard_url="http://localhost:$DASHBOARD_PORT"
    if command -v xdg-open >/dev/null 2>&1; then
        print_status "Opening dashboard in browser..." "info"
        xdg-open "$dashboard_url" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
        print_status "Opening dashboard in browser..." "info"
        open "$dashboard_url" >/dev/null 2>&1 &
    fi
    
    print_status "Dashboard is now running!" "success"
    print_status "Access it at: $dashboard_url" "info"
    
    return 0
}

# Stop the dashboard server
stop_dashboard() {
    if ! is_running; then
        print_status "Dashboard is not running" "warning"
        return 0
    fi
    
    print_status "Stopping Dashboard Server..." "info"
    
    # Stop main server
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE")
        
        if kill "$pid" 2>/dev/null; then
            print_status "Dashboard server stopped" "success"
        else
            print_status "Failed to stop dashboard server (PID: $pid)" "warning"
        fi
        
        rm -f "$PID_FILE"
    fi
    
    # Stop API server
    if [[ -f "$PID_FILE.api" ]]; then
        local api_pid
        api_pid=$(cat "$PID_FILE.api")
        
        if kill "$api_pid" 2>/dev/null; then
            print_status "Dashboard API stopped" "success"
        fi
        
        rm -f "$PID_FILE.api"
    fi
    
    return 0
}

# Restart the dashboard
restart_dashboard() {
    print_status "Restarting Dashboard..." "info"
    stop_dashboard
    sleep 2
    start_dashboard
}

# Open dashboard in browser
open_dashboard() {
    local dashboard_url="http://localhost:$DASHBOARD_PORT"
    
    if ! is_running; then
        print_status "Dashboard is not running. Starting it first..." "warning"
        start_dashboard || return $EXIT_FAILURE
        sleep 3
    fi
    
    print_status "Opening dashboard: $dashboard_url" "info"
    
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$dashboard_url" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
        open "$dashboard_url" >/dev/null 2>&1 &
    else
        print_status "Please open your browser and navigate to: $dashboard_url" "info"
    fi
}

# Show dashboard logs
show_logs() {
    local lines="${1:-50}"
    
    if [[ -f "$LOG_FILE" ]]; then
        print_status "Dashboard logs (last $lines lines):" "info"
        tail -n "$lines" "$LOG_FILE"
    else
        print_status "No dashboard logs found" "warning"
    fi
}

# Print help information
print_help() {
    cat << 'EOF'
Dashboard Server Manager

USAGE:
    dashboard-server.sh <command> [options]

COMMANDS:
    start       Start the dashboard server
    stop        Stop the dashboard server  
    restart     Restart the dashboard server
    status      Show dashboard status
    open        Open dashboard in browser
    logs        Show dashboard logs [lines]
    help        Show this help message

EXAMPLES:
    dashboard-server.sh start           # Start dashboard
    dashboard-server.sh open            # Open in browser
    dashboard-server.sh logs 100        # Show last 100 log lines
    dashboard-server.sh status          # Check if running

CONFIGURATION:
    DASHBOARD_PORT    HTTP server port (default: 8080)
    API_PORT          API server port (default: 8081)

The dashboard provides a web interface for monitoring:
    - System health and performance
    - Test results and coverage
    - Plugin management
    - Real-time logs and metrics
EOF
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        "start")
            start_dashboard
            ;;
        "stop")
            stop_dashboard
            ;;
        "restart")
            restart_dashboard
            ;;
        "status")
            get_status
            ;;
        "open"|"dashboard")
            open_dashboard
            ;;
        "logs")
            show_logs "${2:-50}"
            ;;
        "help"|"--help"|"-h")
            print_help
            ;;
        *)
            print_status "Unknown command: $command" "error"
            echo ""
            print_help
            exit $EXIT_INVALID_ARGS
            ;;
    esac
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
