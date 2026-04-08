#!/usr/bin/env bash
# Lint Claude Code skills for consistency
# shellcheck source=scripts/utils/simple-init.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/simple-init.sh"

SKILLS_DIR="${DOTFILES_ROOT}/home/dot_agents/skills"
errors=0
warnings=0

check_fail() {
    local file="$1" msg="$2"
    log_error "  ${file}: ${msg}"
    errors=$((errors + 1))
}

check_warn() {
    local file="$1" msg="$2"
    log_warning "  ${file}: ${msg}"
    warnings=$((warnings + 1))
}

# Check each skill directory
for skill_dir in "${SKILLS_DIR}"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    log_info "Checking skill: ${skill_name}"

    # 1. SKILL.md must exist
    skill_md="${skill_dir}SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
        check_fail "$skill_name" "missing SKILL.md"
        continue
    fi

    # 2. SKILL.md must have required frontmatter fields
    for field in "name:" "description:" "metadata:"; do
        if ! grep -q "^${field}" "$skill_md" 2>/dev/null; then
            check_fail "SKILL.md" "missing frontmatter field: ${field}"
        fi
    done

    # 3. Description should have TRIGGER/DO NOT TRIGGER
    # Join frontmatter into single line, collapse whitespace for YAML folded scalars
    skill_desc=$(sed -n '2,/^---$/p' "$skill_md" | sed '/^---$/d' | tr '\n' ' ' | tr -s ' ')
    if ! echo "$skill_desc" | grep -q "TRIGGER when:"; then
        check_warn "SKILL.md" "missing 'TRIGGER when:' in description"
    fi
    if ! echo "$skill_desc" | grep -q "DO NOT TRIGGER"; then
        check_warn "SKILL.md" "missing 'DO NOT TRIGGER' in description"
    fi

    # 4. Check sub-files for consistent frontmatter
    while IFS= read -r -d '' md_file; do
        [[ "$md_file" == "$skill_md" ]] && continue
        rel_path="${md_file#"${SKILLS_DIR}/"}"

        # Must have YAML frontmatter
        first_line=$(head -1 "$md_file")
        if [[ "$first_line" != "---" ]]; then
            check_warn "$rel_path" "missing YAML frontmatter"
            continue
        fi

        # Extract frontmatter (between first and second ---)
        frontmatter=$(sed -n '1,/^---$/{ /^---$/d; p; }' "$md_file" | sed '1d')

        # Check for tags as YAML array (should be comma-separated string)
        if echo "$frontmatter" | grep -qE 'tags:\s*\['; then
            check_fail "$rel_path" "tags should be comma-separated string, not YAML array"
        fi

        # Check for impact field
        if ! echo "$frontmatter" | grep -q "^impact:"; then
            check_warn "$rel_path" "missing 'impact' field"
        fi

        # Check for impactDescription field (if impact exists)
        if echo "$frontmatter" | grep -q "^impact:" && \
           ! echo "$frontmatter" | grep -q "^impactDescription:"; then
            check_warn "$rel_path" "has 'impact' but missing 'impactDescription'"
        fi

    done < <(find "$skill_dir" -name '*.md' -print0)

    # 5. Check reading guide references point to real files
    if grep -qE '^\|.*\|.*\|' "$skill_md" 2>/dev/null; then
        ref_files=""
        ref_files=$(grep -oE '\`[a-z][-a-z/]*\.md\`' "$skill_md" 2>/dev/null | tr -d '`' || true)
        for ref in $ref_files; do
            if [[ ! -f "${skill_dir}${ref}" ]]; then
                check_fail "SKILL.md" "reading guide references non-existent file: ${ref}"
            fi
        done
    fi

    # 6. Check "See also" references point to real skills
    if grep -q "## See also" "$skill_md" 2>/dev/null; then
        see_also_skills=""
        see_also_skills=$(sed -n '/## See also/,/^## /p' "$skill_md" | \
            grep -oE '^- \`[a-z][-a-z]*\`' 2>/dev/null | \
            grep -oE '\`[a-z][-a-z]*\`' | tr -d '`' | sort -u || true)
        for ref_skill in $see_also_skills; do
            if [[ ! -d "${SKILLS_DIR}/${ref_skill}" ]]; then
                check_fail "SKILL.md" "See also references non-existent skill: ${ref_skill}"
            fi
        done
    fi
done

# Summary
echo ""
if [[ $errors -gt 0 ]]; then
    log_error "Skills lint: ${errors} error(s), ${warnings} warning(s)"
    exit 1
elif [[ $warnings -gt 0 ]]; then
    log_warning "Skills lint: 0 errors, ${warnings} warning(s)"
    exit 0
else
    log_success "Skills lint: all checks passed"
    exit 0
fi
