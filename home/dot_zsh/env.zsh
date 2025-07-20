# shellcheck disable=all
# Environment settings for DROO's dotfiles
# This file contains chezmoi template syntax which will be processed by chezmoi

# DappSnap - Automatically use the correct Node.js version
{{- if .nvm -}}
cd() { builtin cd "$@" && if [ -f ".nvmrc" ]; then nvm use; elif [ -d "node_modules" ]; then nvm use 23.4.0; fi }
# Initial setup for current directory
if [ -d "{{ .chezmoi.homeDir }}/Documents/CODE/dappsnap/node_modules" ]; then nvm use 23.4.0; fi
{{- end -}}

# Work-specific settings
{{- if .work -}}
export GIT_AUTHOR_EMAIL="{{ .email }}"
export GIT_COMMITTER_EMAIL="{{ .email }}"
export GITHUB_TOKEN=your_personal_access_token
# Add work-specific configs here
{{- end -}}

# GitHub token (if not in work mode)
{{- if not .work -}}
export GITHUB_TOKEN=your_personal_access_token
{{- end -}} 