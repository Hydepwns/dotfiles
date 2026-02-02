# shellcheck disable=all
# Prompt configuration - Starship
# Falls back to simple prompt if Starship not installed

# Check if Starship is available
if command -v starship &>/dev/null; then
    # Initialize Starship prompt
    eval "$(starship init zsh)"
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
