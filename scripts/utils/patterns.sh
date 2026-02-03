#!/usr/bin/env bash

# Consolidated Patterns Library
# Eliminates repetitive code patterns across the entire framework

# Network and API patterns
# ========================

# Unified HTTP request with retry and error handling
http_request() {
    local url="$1"
    local method="${2:-GET}"
    local data="${3:-}"
    local headers="${4:-}"
    local timeout="${5:-30}"
    local retries="${6:-3}"
    
    local curl_args=(-s -L --max-time "$timeout")
    
    # Add method
    [[ "$method" != "GET" ]] && curl_args+=(-X "$method")
    
    # Add data
    [[ -n "$data" ]] && curl_args+=(-d "$data")
    
    # Add headers
    if [[ -n "$headers" ]]; then
        while IFS= read -r header; do
            [[ -n "$header" ]] && curl_args+=(-H "$header")
        done <<< "$headers"
    fi
    
    # Attempt request with retries
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        if curl "${curl_args[@]}" "$url" 2>/dev/null; then
            return 0
        fi
        
        [[ $attempt -lt $retries ]] && sleep $((attempt * 2))
        ((attempt++))
    done
    
    return 1
}

# GitHub API helper
github_api() {
    local endpoint="$1"
    local method="${2:-GET}"
    local data="${3:-}"
    
    local headers="Accept: application/vnd.github.v3+json"
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        headers+=$'\n'"Authorization: token $GITHUB_TOKEN"
    fi
    
    http_request "https://api.github.com/$endpoint" "$method" "$data" "$headers"
}

# File and Path Operations
# ========================

# Smart path resolution with caching
declare -A PATH_CACHE
resolve_path() {
    local path="$1"
    local cache_key="path:$path"
    
    if [[ -n "${PATH_CACHE[$cache_key]:-}" ]]; then
        echo "${PATH_CACHE[$cache_key]}"
        return 0
    fi
    
    local resolved
    if [[ -e "$path" ]]; then
        resolved="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    else
        resolved="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    fi
    
    PATH_CACHE[$cache_key]="$resolved"
    echo "$resolved"
}

# Unified file existence check with multiple possibilities
find_file() {
    local name="$1"
    shift
    local search_paths=("$@")
    
    # Default search paths if none provided
    if [[ ${#search_paths[@]} -eq 0 ]]; then
        search_paths=(
            "."
            "$HOME"
            "$DOTFILES_ROOT"
            "$UTILS_DIR"
            "/usr/local/bin"
            "/usr/bin"
        )
    fi
    
    for path in "${search_paths[@]}"; do
        local full_path="$path/$name"
        if [[ -f "$full_path" ]]; then
            echo "$full_path"
            return 0
        fi
    done
    
    return 1
}

# Configuration Management Patterns
# =================================

# Unified configuration reader for multiple formats
read_config() {
    local file="$1"
    local key="$2"
    local format="${3:-auto}"
    
    [[ ! -f "$file" ]] && return 1
    
    # Auto-detect format
    if [[ "$format" == "auto" ]]; then
        case "${file##*.}" in
            "toml") format="toml" ;;
            "json") format="json" ;;
            "yaml"|"yml") format="yaml" ;;
            "env") format="env" ;;
            *) format="shell" ;;
        esac
    fi
    
    case "$format" in
        "toml")
            grep -E "^${key}\s*=" "$file" 2>/dev/null | cut -d'=' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^["'\'']*//;s/["'\'']*$//'
            ;;
        "json")
            if has_command jq; then
                jq -r ".$key // empty" "$file" 2>/dev/null
            else
                grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" | cut -d'"' -f4
            fi
            ;;
        "yaml")
            if has_command yq; then
                yq eval ".$key" "$file" 2>/dev/null
            else
                grep -E "^${key}:" "$file" | cut -d':' -f2- | sed 's/^[[:space:]]*//'
            fi
            ;;
        "env")
            grep -E "^${key}=" "$file" | cut -d'=' -f2- | sed 's/^["'\'']*//;s/["'\'']*$//'
            ;;
        "shell")
            source "$file" 2>/dev/null && echo "${!key:-}"
            ;;
    esac
}

# Write configuration with backup
write_config() {
    local file="$1"
    local key="$2"  
    local value="$3"
    local format="${4:-auto}"
    local backup="${5:-true}"
    
    # Auto-detect format
    if [[ "$format" == "auto" ]]; then
        case "${file##*.}" in
            "toml") format="toml" ;;
            "json") format="json" ;;
            "yaml"|"yml") format="yaml" ;;
            "env") format="env" ;;
            *) format="shell" ;;
        esac
    fi
    
    # Create backup
    if [[ "$backup" == "true" ]] && [[ -f "$file" ]]; then
        cp "$file" "${file}.backup.$(get_timestamp file)"
    fi
    
    ensure_dir "$(dirname "$file")"
    
    case "$format" in
        "toml"|"env"|"shell")
            # Simple key=value format
            if grep -q "^${key}=" "$file" 2>/dev/null; then
                sed -i "s/^${key}=.*/${key}=${value}/" "$file"
            else
                echo "${key}=${value}" >> "$file"
            fi
            ;;
        "json")
            if has_command jq; then
                local temp_file
                temp_file=$(create_temp file)
                jq ".${key} = \"${value}\"" "$file" > "$temp_file" && mv "$temp_file" "$file"
            else
                echo "ERROR: JSON writing requires jq" >&2
                return 1
            fi
            ;;
    esac
}

# Process Management Patterns
# ===========================

# Unified process management
manage_process() {
    local action="$1"
    local pid_file="$2"
    local command="${3:-}"
    
    case "$action" in
        "start")
            if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
                echo "Process already running (PID: $(cat "$pid_file"))"
                return 1
            fi
            
            ensure_dir "$(dirname "$pid_file")"
            eval "$command" &
            echo $! > "$pid_file"
            echo "Started process (PID: $!)"
            ;;
        "stop")
            if [[ -f "$pid_file" ]]; then
                local pid
                pid=$(cat "$pid_file")
                if kill "$pid" 2>/dev/null; then
                    echo "Stopped process (PID: $pid)"
                    rm -f "$pid_file"
                else
                    echo "Process not running or already stopped"
                    rm -f "$pid_file"
                fi
            else
                echo "No PID file found"
                return 1
            fi
            ;;
        "status")
            if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
                echo "Running (PID: $(cat "$pid_file"))"
                return 0
            else
                echo "Not running"
                [[ -f "$pid_file" ]] && rm -f "$pid_file"
                return 1
            fi
            ;;
        "restart")
            manage_process "stop" "$pid_file"
            sleep 2
            manage_process "start" "$pid_file" "$command"
            ;;
    esac
}

# Data Processing Patterns
# ========================

# Unified data validation
validate_data() {
    local data="$1"
    local type="$2"
    local constraints="${3:-}"
    
    case "$type" in
        "email")
            [[ "$data" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
            ;;
        "url")
            [[ "$data" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]
            ;;
        "number")
            [[ "$data" =~ ^[0-9]+$ ]]
            ;;
        "float")
            [[ "$data" =~ ^[0-9]+(\.[0-9]+)?$ ]]
            ;;
        "version")
            [[ "$data" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
            ;;
        "path")
            [[ -e "$data" ]]
            ;;
        "file")
            [[ -f "$data" ]]
            ;;
        "directory")
            [[ -d "$data" ]]
            ;;
        "not_empty")
            [[ -n "$data" ]]
            ;;
        "min_length")
            [[ ${#data} -ge ${constraints:-1} ]]
            ;;
        "max_length")
            [[ ${#data} -le ${constraints:-100} ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Archive and Compression Patterns
# ================================

# Unified archive operations
manage_archive() {
    local action="$1"
    local archive="$2"
    local target="${3:-.}"
    
    case "$action" in
        "create")
            case "${archive##*.}" in
                "tar.gz"|"tgz")
                    tar -czf "$archive" "$target"
                    ;;
                "tar.bz2"|"tbz")
                    tar -cjf "$archive" "$target"
                    ;;
                "tar.xz"|"txz")
                    tar -cJf "$archive" "$target"
                    ;;
                "zip")
                    if has_command zip; then
                        zip -r "$archive" "$target"
                    else
                        echo "ERROR: zip command not available" >&2
                        return 1
                    fi
                    ;;
                *)
                    echo "ERROR: Unsupported archive format" >&2
                    return 1
                    ;;
            esac
            ;;
        "extract")
            case "${archive##*.}" in
                "tar.gz"|"tgz")
                    tar -xzf "$archive" -C "$target"
                    ;;
                "tar.bz2"|"tbz")
                    tar -xjf "$archive" -C "$target"
                    ;;
                "tar.xz"|"txz")
                    tar -xJf "$archive" -C "$target"
                    ;;
                "zip")
                    if has_command unzip; then
                        unzip "$archive" -d "$target"
                    else
                        echo "ERROR: unzip command not available" >&2
                        return 1
                    fi
                    ;;
                *)
                    echo "ERROR: Unsupported archive format" >&2
                    return 1
                    ;;
            esac
            ;;
        "list")
            case "${archive##*.}" in
                "tar.gz"|"tgz")
                    tar -tzf "$archive"
                    ;;
                "tar.bz2"|"tbz")
                    tar -tjf "$archive"
                    ;;
                "tar.xz"|"txz")
                    tar -tJf "$archive"
                    ;;
                "zip")
                    if has_command unzip; then
                        unzip -l "$archive"
                    else
                        echo "ERROR: unzip command not available" >&2
                        return 1
                    fi
                    ;;
                *)
                    echo "ERROR: Unsupported archive format" >&2
                    return 1
                    ;;
            esac
            ;;
    esac
}

# Template Processing Patterns
# ============================

# Simple template variable substitution
process_template() {
    local template_file="$1"
    local output_file="$2"
    local variables_file="${3:-}"
    
    [[ ! -f "$template_file" ]] && return 1
    
    local temp_content
    temp_content=$(<"$template_file")
    
    # Load variables if provided
    if [[ -n "$variables_file" ]] && [[ -f "$variables_file" ]]; then
        source "$variables_file"
    fi
    
    # Replace environment variables
    temp_content=$(envsubst <<< "$temp_content")
    
    # Write output
    ensure_dir "$(dirname "$output_file")"
    echo "$temp_content" > "$output_file"
}

# Export all functions
export -f http_request github_api resolve_path find_file read_config write_config
export -f manage_process validate_data manage_archive process_template