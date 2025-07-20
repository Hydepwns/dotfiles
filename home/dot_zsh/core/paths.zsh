# shellcheck disable=all
# Centralized PATH management for DROO's dotfiles
# This file contains chezmoi template syntax which will be processed by chezmoi

# PATH registry
declare -A PATH_REGISTRY=(
    # Base paths
    ["base"]="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    # Platform-specific paths
    ["macos_brew"]="{{ .brewPrefix }}/bin:{{ .brewPrefix }}/sbin"
    ["linux_local"]="/usr/local/bin"

    # Tool-specific paths
    ["rust"]="{{ .chezmoi.homeDir }}/.cargo/bin"
    ["nodejs"]="{{ .chezmoi.homeDir }}/.asdf/installs/nodejs/18.19.0/bin"
    ["pnpm_macos"]="{{ .chezmoi.homeDir }}/Library/pnpm"
    ["pnpm_linux"]="{{ .chezmoi.homeDir }}/.local/share/pnpm"
    ["pipx"]="{{ .chezmoi.homeDir }}/.local/bin"

    # Web3 tools
    ["foundry"]="{{ .chezmoi.homeDir }}/.foundry/bin"
    ["huff"]="{{ .chezmoi.homeDir }}/.huff/bin"
    ["solana"]="{{ .chezmoi.homeDir }}/.local/share/solana/install/active_release/bin"

    # Development tools
    ["llvm"]="/opt/homebrew/opt/llvm/bin"
    ["postgres_homebrew"]="/opt/homebrew/opt/postgresql@15/bin"
    ["postgres_app"]="/Applications/Postgres.app/Contents/Versions/15/bin"
    ["python_arm64"]="/opt/homebrew/opt/python@3.8/bin"
    ["python_intel"]="/usr/local/opt/python@3.9/bin"

    # Version managers
    ["rbenv"]="{{ .chezmoi.homeDir }}/.rbenv/shims"
    ["nvm"]="{{ .chezmoi.homeDir }}/.nvm"
    ["asdf"]="{{ .brewPrefix }}/opt/asdf/libexec"
    ["erlang"]="{{ .brewPrefix }}/opt/erlang/bin"
    ["elixir_mix"]="{{ .chezmoi.homeDir }}/.mix/escripts"
    ["lua_luarocks"]="{{ .chezmoi.homeDir }}/.luarocks/bin"

    # Nix paths
    ["nix_profile"]="/nix/var/nix/profiles/default/bin"
    ["nix_daemon"]="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    ["nix_profile_script"]="{{ .chezmoi.homeDir }}/.nix-profile/etc/profile.d/nix.sh"
)

# Function to add path safely
add_to_path() {
    local path_to_add="$1"
    local position="${2:-end}"  # "begin" or "end"

    if [[ -d "$path_to_add" ]]; then
        case "$position" in
            "begin")
                export PATH="$path_to_add:$PATH"
                ;;
            "end")
                export PATH="$PATH:$path_to_add"
                ;;
        esac
    fi
}

# Build PATH based on configuration
build_path() {
    # Start with base path
    export PATH="${PATH_REGISTRY[base]}"

    # Add platform-specific paths
    {{- if eq .chezmoi.os "darwin" -}}
    add_to_path "${PATH_REGISTRY[macos_brew]}" "begin"

    # macOS-specific development tools
    {{- if .llvm -}}add_to_path "${PATH_REGISTRY[llvm]}"{{- end -}}
    {{- if .postgres -}}add_to_path "${PATH_REGISTRY[postgres_homebrew]}"{{- end -}}
    {{- if .psql -}}add_to_path "${PATH_REGISTRY[postgres_app]}"{{- end -}}

    # Architecture-specific Python paths
    {{- if eq .chezmoi.arch "arm64" -}}
    add_to_path "${PATH_REGISTRY[python_arm64]}"
    {{- else -}}
    add_to_path "${PATH_REGISTRY[python_intel]}"
    {{- end -}}

    {{- else if eq .chezmoi.os "linux" -}}
    add_to_path "${PATH_REGISTRY[linux_local]}" "begin"
    {{- end -}}

    # Add tool-specific paths based on configuration
    {{- if .rust -}}add_to_path "${PATH_REGISTRY[rust]}"{{- end -}}
    {{- if .nodejs -}}add_to_path "${PATH_REGISTRY[nodejs]}"{{- end -}}
    {{- if .foundry -}}add_to_path "${PATH_REGISTRY[foundry]}"{{- end -}}
    {{- if .huff -}}add_to_path "${PATH_REGISTRY[huff]}"{{- end -}}
    {{- if .solana -}}add_to_path "${PATH_REGISTRY[solana]}"{{- end -}}

    # Add version manager paths
    {{- if .rbenv -}}add_to_path "${PATH_REGISTRY[rbenv]}"{{- end -}}
    {{- if .nvm -}}add_to_path "${PATH_REGISTRY[nvm]}"{{- end -}}
    {{- if .asdf -}}add_to_path "${PATH_REGISTRY[asdf]}"{{- end -}}
    {{- if .erlang -}}add_to_path "${PATH_REGISTRY[erlang]}"{{- end -}}
    {{- if .elixir -}}add_to_path "${PATH_REGISTRY[elixir_mix]}"{{- end -}}
    {{- if .lua -}}add_to_path "${PATH_REGISTRY[lua_luarocks]}"{{- end -}}

    # Add Nix paths
    {{- if .nix -}}
    add_to_path "${PATH_REGISTRY[nix_profile]}"
    {{- end -}}

    # Add package manager paths
    {{- if eq .chezmoi.os "darwin" -}}
    add_to_path "${PATH_REGISTRY[pnpm_macos]}"
    {{- else if eq .chezmoi.os "linux" -}}
    add_to_path "${PATH_REGISTRY[pnpm_linux]}"
    {{- end -}}
    add_to_path "${PATH_REGISTRY[pipx]}"
}

# Initialize PATH
build_path

# Load platform-specific configurations
{{- if eq .chezmoi.os "darwin" -}}
source "{{ .chezmoi.homeDir }}/.zsh/core/platforms/macos.zsh"
{{- else if eq .chezmoi.os "linux" -}}
source "{{ .chezmoi.homeDir }}/.zsh/core/platforms/linux.zsh"
{{- end -}}

# Load tool-specific configurations
source "{{ .chezmoi.homeDir }}/.zsh/core/tools.zsh"

# Load package manager configurations
source "{{ .chezmoi.homeDir }}/.zsh/core/package-managers.zsh"
