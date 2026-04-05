---
title: Chezmoi Template Patterns
impact: MEDIUM
impactDescription: correct templates, no apply failures
tags: chezmoi, templates, go-template, run-onchange, encryption
---

# Chezmoi Template Patterns

## Whitespace Trimming

Always use `{{-` and `-}}` to trim whitespace. Without trimming, templates produce files with unwanted blank lines around conditionals.

### Incorrect

```
# ~/.tool-versions
{{ if .elixir }}
erlang 27.0
elixir 1.17.2-otp-27
{{ end }}
{{ if .rust }}
rust 1.79.0
{{ end }}
python 3.12.4
```

Output has blank lines around each conditional block:

```

erlang 27.0
elixir 1.17.2-otp-27


rust 1.79.0

python 3.12.4
```

### Correct

```
# ~/.tool-versions
{{- if .elixir }}
erlang 27.0
elixir 1.17.2-otp-27
{{- end }}
{{- if .rust }}
rust 1.79.0
{{- end }}
python 3.12.4
```

Clean output:

```
# ~/.tool-versions
erlang 27.0
elixir 1.17.2-otp-27
rust 1.79.0
python 3.12.4
```

## Home Directory References

Use `.chezmoi.homeDir` in templates. Tilde `~` does not expand inside template output -- it becomes a literal `~` in the generated file.

### Incorrect

```
[alias]
    config = !chezmoi edit ~/CODE/dotfiles/chezmoi.toml

[core]
    excludesFile = ~/.config/git/ignore

[include]
    path = ~/CODE/dotfiles/config/git/local.gitconfig
```

These paths contain literal `~` and will not resolve at runtime in most contexts.

### Correct

```
[alias]
    config = !chezmoi edit {{ .chezmoi.homeDir }}/CODE/dotfiles/chezmoi.toml

[core]
    excludesFile = {{ .chezmoi.homeDir }}/.config/git/ignore

[include]
    path = {{ .chezmoi.homeDir }}/CODE/dotfiles/config/git/local.gitconfig
```

## missingkey=error and Flag Guards

Template strictness (`missingkey=error`) means referencing an undefined key is a hard error during `chezmoi apply`. Always verify the flag exists in `chezmoi.toml` before using it.

### Incorrect

```
{{- if .kubernetes -}}
export KUBECONFIG="{{ .chezmoi.homeDir }}/.kube/config"
{{- end -}}
```

If `kubernetes` is not defined in `chezmoi.toml` `[data]`, this is not false -- it is a fatal error:

```
template: ...: error calling ...: map has no entry for key "kubernetes"
```

### Correct

First, add the flag to `chezmoi.toml`:

```toml
[data]
    kubernetes = true
```

Then use it in the template:

```
{{- if .kubernetes -}}
export KUBECONFIG="{{ .chezmoi.homeDir }}/.kube/config"
{{- end -}}
```

If the feature should be off by default, set it to `false` -- the key must still exist.

## run_onchange Script Patterns

Chezmoi re-runs `run_onchange_*` scripts when the rendered script content changes. Embed a hash comment to trigger re-runs when external files change.

### Incorrect

```bash
#!/bin/bash
# run_onchange_after_install-packages.sh.tmpl
#
# No hash -- this script only re-runs when its own source changes.
# Editing Brewfile won't trigger a re-run.

brew bundle install --file="{{ .chezmoi.homeDir }}/CODE/dotfiles/Brewfile"
```

### Correct

```bash
#!/bin/bash
# run_onchange_after_install-packages.sh.tmpl
#
# Brewfile hash: {{ include "Brewfile" | sha256sum }}
#
# The hash comment above changes when Brewfile contents change,
# which changes the rendered script, which triggers chezmoi to re-run it.

set -euo pipefail
brew bundle install --file="{{ .chezmoi.homeDir }}/CODE/dotfiles/Brewfile"
```

The `{{ include "Brewfile" | sha256sum }}` embeds a hash of the Brewfile into the rendered script. When the Brewfile changes, the hash changes, the rendered script changes, and chezmoi detects it as needing to re-run.
