# shellcheck disable=all
# Centralized PATH management for DROO's dotfiles
# This file contains chezmoi template syntax which will be processed by chezmoi

# Base PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Platform-specific PATH setup
{{- if eq .chezmoi.os "darwin" -}}
source "{{ .chezmoi.homeDir }}/.zsh/core/platforms/macos.zsh"
{{- else if eq .chezmoi.os "linux" -}}
source "{{ .chezmoi.homeDir }}/.zsh/core/platforms/linux.zsh"
{{- end -}}

# Tool-specific PATH additions
source "{{ .chezmoi.homeDir }}/.zsh/core/tools.zsh"

# Package manager configurations
source "{{ .chezmoi.homeDir }}/.zsh/core/package-managers.zsh" 