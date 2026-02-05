# shellcheck disable=all
# Prompt configuration - Starship (cached for speed)
# Falls back to simple prompt if Starship not installed

if command -v starship &>/dev/null; then
    # Cache starship init output (saves ~65ms per shell)
    _starship_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-completions/starship-init.zsh"
    if [[ ! -f "$_starship_cache" ]] || [[ $(find "$_starship_cache" -mtime +1 2>/dev/null) ]]; then
        mkdir -p "$(dirname "$_starship_cache")"
        starship init zsh > "$_starship_cache" 2>/dev/null
    fi
    source "$_starship_cache"
    unset _starship_cache
else
    # Fallback: Simple prompt with git info
    autoload -Uz vcs_info
    precmd_vcs_info() { vcs_info }
    precmd_functions+=( precmd_vcs_info )
    setopt prompt_subst

    zstyle ':vcs_info:git:*' formats '%F{magenta}%b%f '
    zstyle ':vcs_info:*' enable git

    # Simple two-line prompt
    PROMPT='%F{cyan}%~%f ${vcs_info_msg_0_}
%F{green}->%f '
fi
