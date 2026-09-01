#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_file() {
    [[ -f "$1" ]] || fail "missing $1"
}

assert_file "$DOTFILES_ROOT/AGENTS.md"
assert_file "$DOTFILES_ROOT/home/private_dot_codex/AGENTS.md.tmpl"
assert_file "$DOTFILES_ROOT/home/private_dot_codex/hooks.json.tmpl"
assert_file "$DOTFILES_ROOT/home/run_onchange_after_setup-codex.sh.tmpl"
assert_file "$DOTFILES_ROOT/scripts/utils/apply-codex-target.sh"
grep -A5 '^\[".agents/skills-upstream"\]' "$DOTFILES_ROOT/home/.chezmoiexternal.toml" |
    grep -q 'exact = true' || fail "upstream skills external is not exact"

test_home="$WORK_DIR/home"
mkdir -p \
    "$test_home/.agents/skills/core" \
    "$test_home/.agents/skills-upstream/core" \
    "$test_home/.agents/skills-upstream/shared" \
    "$test_home/.agents/skills-extra/extra" \
    "$test_home/.agents/skills-extra/shared"
printf '%s\n' '# legacy' >"$test_home/.agents/skills/core/SKILL.md"
printf '%s\n' '# upstream' >"$test_home/.agents/skills-upstream/core/SKILL.md"
printf '%s\n' '# upstream shared' >"$test_home/.agents/skills-upstream/shared/SKILL.md"
printf '%s\n' '# extra' >"$test_home/.agents/skills-extra/extra/SKILL.md"
printf '%s\n' '# preferred shared' >"$test_home/.agents/skills-extra/shared/SKILL.md"

HOME="$test_home" bash "$DOTFILES_ROOT/home/run_after_sync-skills.sh.tmpl" >/dev/null
[[ -f "$test_home/.agents/skills-before-codex-merge/core/SKILL.md" ]] ||
    fail "legacy skill root was not preserved"
[[ -L "$test_home/.agents/skills/core" ]] || fail "upstream skill was not linked"
[[ -L "$test_home/.agents/skills/extra" ]] || fail "extra skill was not linked"
[[ "$(readlink "$test_home/.agents/skills/shared")" == ../skills-extra/shared ]] ||
    fail "skills-extra did not win the name collision"

# The second run must converge without changing the selected targets.
HOME="$test_home" bash "$DOTFILES_ROOT/home/run_after_sync-skills.sh.tmpl" >/dev/null
[[ "$(readlink "$test_home/.agents/skills/shared")" == ../skills-extra/shared ]] ||
    fail "skill merge is not idempotent"

hooks_json="$WORK_DIR/hooks.json"
chezmoi execute-template <"$DOTFILES_ROOT/home/private_dot_codex/hooks.json.tmpl" >"$hooks_json"
jq -e '.hooks.PreToolUse[0].matcher == "^Bash$"' "$hooks_json" >/dev/null
jq -e '.hooks.SessionStart[0].matcher == "startup|resume"' "$hooks_json" >/dev/null

rendered_git="$WORK_DIR/gitconfig"
chezmoi --source "$DOTFILES_ROOT/home" --working-tree "$DOTFILES_ROOT" \
    cat "$HOME/.gitconfig" >"$rendered_git"
[[ "$(git config --file "$rendered_git" --get user.signingkey)" == key::ssh-ed25519* ]] ||
    fail "rendered Git config lost the SSH signing key"
[[ "$(git config --file "$rendered_git" --get gpg.format)" == ssh ]] ||
    fail "rendered Git config lost SSH signing format"
[[ "$(git config --file "$rendered_git" --get commit.gpgsign)" == true ]] ||
    fail "rendered Git config disabled commit signing"

rendered_zshenv="$WORK_DIR/zshenv"
rendered_zshrc="$WORK_DIR/zshrc"
chezmoi --source "$DOTFILES_ROOT/home" --working-tree "$DOTFILES_ROOT" \
    cat "$HOME/.zshenv" >"$rendered_zshenv"
chezmoi --source "$DOTFILES_ROOT/home" --working-tree "$DOTFILES_ROOT" \
    cat "$HOME/.zshrc" >"$rendered_zshrc"
grep -q '/.foundry/bin' "$rendered_zshenv" || fail "rendered zshenv lost Foundry"
grep -q '/.grok/bin' "$rendered_zshrc" || fail "rendered zshrc lost Grok"
grep -q '/.aztec/current/bin' "$rendered_zshrc" || fail "rendered zshrc lost Aztec"
grep -q 'NARGO_HOME' "$rendered_zshrc" || fail "rendered zshrc lost Nargo"

# Exercise the deployment helper against a recording chezmoi stub. This proves
# it binds the working checkout and never expands into an unscoped home apply.
fake_bin="$WORK_DIR/bin"
chezmoi_args_log="$WORK_DIR/chezmoi-args"
mkdir -p "$fake_bin"
printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\n" "$@" >"$CHEZMOI_ARGS_LOG"' >"$fake_bin/chezmoi"
chmod +x "$fake_bin/chezmoi"
PATH="$fake_bin:$PATH" CHEZMOI_ARGS_LOG="$chezmoi_args_log" \
    "$DOTFILES_ROOT/scripts/utils/apply-codex-target.sh" --dry-run
grep -Fxq -- '--source' "$chezmoi_args_log" || fail "Codex apply did not bind its source"
grep -Fxq -- "$DOTFILES_ROOT/home" "$chezmoi_args_log" || fail "Codex apply used the wrong source"
grep -Fxq -- "$HOME/.agents/skills-upstream" "$chezmoi_args_log" || fail "Codex apply omitted skills"
grep -Fxq -- "$HOME/.codex/AGENTS.md" "$chezmoi_args_log" || fail "Codex apply omitted AGENTS.md"
grep -Fxq -- "$HOME/.codex/hooks.json" "$chezmoi_args_log" || fail "Codex apply omitted hooks"
if grep -Eq '/\.(gitconfig|zshenv|zshrc)$' "$chezmoi_args_log"; then
    fail "Codex apply included unrelated Git or shell files"
fi

git_hook="$DOTFILES_ROOT/home/private_dot_claude/hooks/executable_block-destructive-git.sh"
rm_hook="$DOTFILES_ROOT/home/private_dot_claude/hooks/executable_block-rm-rf.sh"
printf '%s\n' '{"tool_input":{"command":"git reset --hard HEAD"}}' |
    bash "$git_hook" >/dev/null 2>&1 && fail "git hook allowed reset --hard"
printf '%s\n' '{"tool_input":{"command":"git status --short"}}' |
    bash "$git_hook" >/dev/null 2>&1 || fail "git hook blocked a safe command"
printf '%s\n' '{"tool_input":{"command":"rm -rf build"}}' |
    bash "$rm_hook" >/dev/null 2>&1 && fail "rm hook allowed rm -rf"

rendered_setup="$WORK_DIR/setup-codex.sh"
chezmoi execute-template <"$DOTFILES_ROOT/home/run_onchange_after_setup-codex.sh.tmpl" >"$rendered_setup"
bash -n "$rendered_setup"

claude_mcp="$WORK_DIR/mcp.json"
chezmoi execute-template <"$DOTFILES_ROOT/home/dot_mcp.json.tmpl" >"$claude_mcp"
jq -e '.mcpServers.scribe.command == "scribe"' "$claude_mcp" >/dev/null

codex_home="$WORK_DIR/codex"
mkdir -p "$codex_home"
printf '%s\n' \
    'model = "gpt-5.4"' \
    '' \
    '[projects."/tmp/codex-target-test"]' \
    'trust_level = "trusted"' >"$codex_home/config.toml"
CODEX_HOME="$codex_home" codex mcp add keep-me -- true >/dev/null
CODEX_HOME="$codex_home" HOME="$test_home" bash "$rendered_setup" >/dev/null
grep -q '^model = "gpt-5.4"$' "$codex_home/config.toml" || fail "Codex model setting was replaced"
grep -q '^trust_level = "trusted"$' "$codex_home/config.toml" || fail "Codex trust setting was replaced"
CODEX_HOME="$codex_home" codex mcp get keep-me --json |
    jq -e '.transport.command == "true"' >/dev/null
CODEX_HOME="$codex_home" codex mcp get blockscout --json |
    jq -e '.transport.type == "streamable_http" and .transport.url == "https://mcp.blockscout.com/mcp"' >/dev/null
CODEX_HOME="$codex_home" codex mcp get scribe --json |
    jq -e '.transport.type == "stdio" and .transport.command == "scribe" and .transport.args == ["serve"]' >/dev/null

printf 'Codex target checks passed\n'
