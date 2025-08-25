#!/usr/bin/env bash
# Plugin functions

# Example function
example_function() {
    local message="$1"
    plugin_log_info "Example function called with: $message"
    echo "Hello from $PLUGIN_NAME: $message"
}

# Plugin cleanup
plugin_cleanup() {
    plugin_log_info "Cleaning up plugin resources"
}
