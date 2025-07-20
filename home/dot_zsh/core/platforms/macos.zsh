# shellcheck disable=all
# macOS-specific PATH and environment setup
# This file contains chezmoi template syntax which will be processed by chezmoi

# Homebrew configuration
export PATH="{{ .brewPrefix }}/bin:{{ .brewPrefix }}/sbin:$PATH"
eval "$({{ .brewPrefix }}/bin/brew shellenv)"

# Apple Silicon specific configurations
if [[ "$(arch)" = "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    {{- if .llvm -}}export PATH="/opt/homebrew/opt/llvm/bin:$PATH"{{- end -}}
    {{- if .postgres -}}export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"{{- end -}}
    export PATH="/opt/homebrew/opt/python@3.8/bin:$PATH"
else
    eval "$(/usr/local/bin/brew shellenv)"
    export PATH="/usr/local/opt/python@3.9/bin:$PATH"
fi

# PostgreSQL configuration
{{- if .psql -}}
export PATH="/Applications/Postgres.app/Contents/Versions/15/bin:$PATH"
{{- end -}}

# Web3 tool configurations
{{- if .foundry -}}
export PATH="$PATH:{{ .chezmoi.homeDir }}/.foundry/bin"
{{- end -}}

{{- if .huff -}}
export PATH="$PATH:{{ .chezmoi.homeDir }}/.huff/bin"
{{- end -}}

{{- if .solana -}}
export PATH="{{ .chezmoi.homeDir }}/.local/share/solana/install/active_release/bin:$PATH"
{{- end -}}

# macOS-specific aliases
alias copy="pbcopy"
alias paste="pbpaste"
alias ls="ls -G"
alias flushdns="sudo dscacheutil -flushcache"

# iTerm2 integration
test -e "{{ .chezmoi.homeDir }}/.iterm2_shell_integration.zsh" && source "{{ .chezmoi.homeDir }}/.iterm2_shell_integration.zsh" 