# shellcheck disable=all
# Configuration registry for DROO's dotfiles
# This file contains chezmoi template syntax which will be processed by chezmoi

# Configuration registry for all tools
declare -A TOOL_CONFIGS=(
    ["rust"]="cargo"
    ["nodejs"]="node"
    ["python"]="python3"
    ["elixir"]="elixir"
    ["go"]="go"
    ["lua"]="lua"
    ["docker"]="docker"
    ["git"]="git"
)

# Function to check if tool is available
tool_available() {
    local tool="$1"
    command -v "$tool" &> /dev/null
}

# Function to load tool configuration
load_tool_config() {
    local tool="$1"
    local config_file="{{ .chezmoi.homeDir }}/.zsh/tools/${tool}.zsh"

    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

# Function to check if a configuration is enabled
config_enabled() {
    local config="$1"
    {{- if .config_check -}}
    # This would be replaced by chezmoi template logic
    return 0
    {{- else -}}
    return 1
    {{- end -}}
}

# Universal settings
export EDITOR="nvim"
export LANG="en_US.UTF-8"

# Common aliases (cross-platform)
alias ll="ls -la"
alias g="git"
alias cm="chezmoi"

# VS Code integration
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args "$@" ;}
