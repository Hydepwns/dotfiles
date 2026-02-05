#!/usr/bin/env bash

# Dotfiles health check
# Usage: make doctor

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/simple-init.sh"

print_section() { echo -e "\n${YELLOW:-}--- $1 ---${NC:-}"; }
print_ok() { echo -e "  ${GREEN:-}[ok]${NC:-} $1"; }
print_warn() { echo -e "  ${YELLOW:-}[!!]${NC:-} $1"; }
print_fail() { echo -e "  ${RED:-}[xx]${NC:-} $1"; }

PASS=0; WARN=0; FAIL=0
ok()   { print_ok   "$1"; PASS=$((PASS + 1)); }
warn() { print_warn "$1"; WARN=$((WARN + 1)); }
fail() { print_fail "$1"; FAIL=$((FAIL + 1)); }

check_cmd() {
    local cmd="$1" level="${2:-warn}"
    if command -v "$cmd" &>/dev/null; then
        local ver
        ver=$("$cmd" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+[^ ]*' | head -1 || true)
        ok "$cmd${ver:+ $ver}"
    else
        "$level" "$cmd not found"
    fi
}

log_info "Running dotfiles health check..."

# -- Core --
print_section "Core"
check_cmd chezmoi fail
check_cmd git fail
check_cmd zsh fail
if [[ "$OSTYPE" == "darwin"* ]]; then
    check_cmd brew warn
fi

# -- Shell --
print_section "Shell"
if [[ -f "$HOME/.zshrc" ]]; then
    ok ".zshrc exists ($(wc -l < "$HOME/.zshrc" | tr -d ' ') lines)"
else
    fail ".zshrc missing"
fi

if [[ -f "$HOME/.zsh/modules.zsh" ]]; then
    ok "modules.zsh loaded"
else
    fail "modules.zsh missing"
fi

if command -v starship &>/dev/null && [[ -f "$HOME/.config/starship/starship.toml" ]]; then
    ok "Starship prompt configured"
elif command -v starship &>/dev/null; then
    warn "Starship installed but config missing"
else
    warn "Starship not installed"
fi

# -- Terminal tools --
print_section "Terminal Tools"
for tool in fzf zoxide eza bat fd rg yazi btop fastfetch tldr delta; do
    check_cmd "$tool"
done

# -- Dev tools --
print_section "Development"
check_cmd mise warn
check_cmd direnv warn
check_cmd nvim warn

if command -v node &>/dev/null; then
    ok "node $(node --version 2>/dev/null || true)"
else
    warn "node not found"
fi

if command -v rustc &>/dev/null; then
    ok "rustc $(rustc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)"
else
    warn "rustc not found"
fi

if command -v python3 &>/dev/null; then
    ok "python3 $(python3 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)"
else
    warn "python3 not found"
fi

if command -v elixir &>/dev/null; then
    ok "elixir installed"
else
    warn "elixir not found"
fi

# -- Encryption --
print_section "Encryption"
AGE_KEY="$HOME/.config/chezmoi/age_key.txt"
if [[ -f "$AGE_KEY" ]]; then
    perms=$(stat -f '%Lp' "$AGE_KEY" 2>/dev/null) || perms=$(stat -c '%a' "$AGE_KEY" 2>/dev/null) || perms="unknown"
    if [[ "$perms" == "600" ]]; then
        ok "age key (mode 600)"
    else
        warn "age key mode $perms (should be 600)"
    fi
else
    fail "age key missing"
fi
check_cmd age fail

# -- Git --
print_section "Git"
if git config user.name &>/dev/null; then
    ok "$(git config user.name) <$(git config user.email)>"
else
    fail "git user not configured"
fi

if git config commit.gpgsign &>/dev/null; then
    ok "GPG signing enabled"
else
    warn "GPG signing not configured"
fi

# -- SSH --
print_section "SSH"
ssh_keys=$(ssh-add -l 2>/dev/null || true)
if [[ -n "$ssh_keys" ]] && [[ "$ssh_keys" != *"no identities"* ]]; then
    ok "SSH keys loaded: $(echo "$ssh_keys" | head -1 | rev | cut -d' ' -f1 | rev)"
else
    warn "no SSH keys loaded"
fi

# -- Chezmoi --
print_section "Chezmoi"
if [[ -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
    ok "chezmoi.toml exists"
else
    fail "chezmoi.toml missing"
fi

drift=$(chezmoi status 2>/dev/null | wc -l | tr -d ' ' || echo "0")
if [[ "$drift" -eq 0 ]]; then
    ok "no drift"
else
    warn "$drift file(s) have drift (run chezmoi diff)"
fi

# -- Summary --
echo ""
echo "---"
total=$((PASS + WARN + FAIL))
printf "Results: %d passed, %d warnings, %d failed (%d total)\n" "$PASS" "$WARN" "$FAIL" "$total"

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
else
    log_success "Health check complete!"
fi
