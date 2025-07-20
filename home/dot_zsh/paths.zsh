# shellcheck disable=all
# DEPRECATED: This file is deprecated in favor of the new modular structure
# Use home/dot_zsh/core/paths.zsh instead
# This file contains chezmoi template syntax which will be processed by chezmoi

# Load the new modular PATH management
source "{{ .chezmoi.homeDir }}/.zsh/core/paths.zsh"

# Additional tool configurations
{{- if .llvm -}}
# LLVM configuration
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
{{- end -}}

{{- if .postgres -}}
# PostgreSQL configuration
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/Applications/Postgres.app/Contents/Versions/15/bin:$PATH"
{{- end -}}

{{- if .foundry -}}
# Foundry configuration
export PATH="$PATH:{{ .chezmoi.homeDir }}/.foundry/bin"
{{- end -}}

{{- if .huff -}}
# Huff configuration
export PATH="$PATH:{{ .chezmoi.homeDir }}/.huff/bin"
{{- end -}}

{{- if .solana -}}
# Solana configuration
export PATH="{{ .chezmoi.homeDir }}/.local/share/solana/install/active_release/bin:$PATH"
{{- end -}}

# Ruby/rbenv configuration
{{- if .rbenv -}}
export PATH="{{ .chezmoi.homeDir }}/.rbenv/shims:$PATH"
eval "$(rbenv init -)"
{{- end -}} 