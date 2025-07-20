# shellcheck disable=all
# Tool-specific configurations for DROO's dotfiles
# This file contains chezmoi template syntax which will be processed by chezmoi

# Rust configuration
{{- if .rust -}}
export PATH="{{ .chezmoi.homeDir }}/.cargo/bin:$PATH"
{{- end -}}

# NVM configuration
{{- if .nvm -}}
export NVM_DIR="{{ .chezmoi.homeDir }}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
{{- end -}}

# Additional Node.js configuration
{{- if .nodejs -}}
export PATH="{{ .chezmoi.homeDir }}/.asdf/installs/nodejs/18.19.0/bin:$PATH"
{{- end -}}

# asdf configuration (consolidated)
{{- if .asdf -}}
. {{ .brewPrefix }}/opt/asdf/libexec/asdf.sh
{{- else -}}
# Additional asdf configuration (always loaded if asdf is present)
if command -v asdf &> /dev/null; then
    . {{ .brewPrefix }}/opt/asdf/libexec/asdf.sh
fi
{{- end -}}

# Elixir configuration
{{- if .elixir -}}
# Add Elixir to PATH (assuming installed via Homebrew or asdf)
export PATH="$PATH:{{ .chezmoi.homeDir }}/.mix/escripts"
# Initialize Elixir version manager if using kiex
if command -v kiex &> /dev/null; then
    eval "$(kiex init)"
fi
{{- end -}}

# Erlang configuration
{{- if .erlang -}}
export PATH="{{ .brewPrefix }}/opt/erlang/bin:$PATH"
{{- end -}}

# Lua configuration
{{- if .lua -}}
# Add Lua to PATH (assuming installed via Homebrew or asdf)
export PATH="$PATH:{{ .chezmoi.homeDir }}/.luarocks/bin"
# Initialize Lua version manager if using luaenv
if command -v luaenv &> /dev/null; then
    eval "$(luaenv init -)"
fi
{{- end -}}

# direnv configuration
{{- if .direnv -}}
# direnv - automatically load environment variables from .envrc files
eval "$(direnv hook zsh)"
{{- end -}}

# devenv configuration
{{- if .devenv -}}
# devenv - Nix-based development environment manager
export DEVENV_DOTFILE=.devenv
export DEVENV_PROFILE=.devenv/.profile
{{- end -}}

# Nix-specific settings (consolidated)
{{- if .nix -}}
# Nix shell integration
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
fi
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
export PATH="/nix/var/nix/profiles/default/bin:$PATH"
{{- else -}}
# Additional Nix configuration (always loaded if Nix is present)
if command -v nix &> /dev/null; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
fi
{{- end -}} 