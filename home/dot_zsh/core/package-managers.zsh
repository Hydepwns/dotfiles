# shellcheck disable=all
# Package manager configurations for DROO's dotfiles
# This file contains chezmoi template syntax which will be processed by chezmoi

# pnpm configuration
{{- if eq .chezmoi.os "darwin" -}}
export PNPM_HOME="{{ .chezmoi.homeDir }}/Library/pnpm"
{{- else if eq .chezmoi.os "linux" -}}
export PNPM_HOME="{{ .chezmoi.homeDir }}/.local/share/pnpm"
{{- end -}}
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pipx configuration
export PATH="$PATH:{{ .chezmoi.homeDir }}/.local/bin" 