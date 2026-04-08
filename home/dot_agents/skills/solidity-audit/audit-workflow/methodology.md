---
title: Audit Methodology
impact: CRITICAL
impactDescription: Foundational 4-phase audit process covering scoping, automated analysis, manual review, and severity classification
tags: solidity, audit, methodology, slither, mythril
---

# Audit Methodology

## 4-Phase Audit Process

### Phase 1: Scoping

1. **Read the documentation** -- whitepaper, specs, architecture docs
2. **Identify the threat model** -- who are the actors? What are their capabilities?
3. **Map the attack surface** -- external functions, privileged roles, external dependencies
4. **Determine invariants** -- what properties must ALWAYS hold?

```
Invariant examples:
- totalSupply == sum(balances)
- No user can withdraw more than they deposited
- Only admin can pause
- Price oracle deviation < 5%
- Collateral ratio >= 150% for all positions
```

### Phase 2: Automated Analysis

Run static analysis tools before manual review to catch low-hanging fruit.

```bash
# Slither -- static analysis (fastest, broadest)
slither . --filter-paths "test|script|lib"

# Specific detectors
slither . --detect reentrancy-eth,reentrancy-no-eth,unprotected-upgrade

# Print function summary
slither . --print function-summary

# Mythril -- symbolic execution (slower, deeper)
myth analyze src/Vault.sol --solc-json mythril.config.json

# Aderyn -- Rust-based static analysis
aderyn .
```

**Automated tools catch ~30% of real vulnerabilities.** They excel at:
- Reentrancy patterns
- Unchecked return values
- Uninitialized storage
- tx.origin usage
- Floating pragmas

They miss:
- Business logic errors
- Economic attacks
- Cross-contract interactions
- Incorrect access control design

### Phase 3: Manual Review

Two-pass approach (adapted from scv-scan methodology):

**Pass A -- Syntactic (line-by-line):**
- Read every line of in-scope code
- Check each function against the vulnerability checklist:
  - [ ] CEI pattern followed?
  - [ ] Access control present on state-changing functions?
  - [ ] Input validation on external parameters?
  - [ ] Integer overflow possible? (Solidity 0.8+ has built-in checks)
  - [ ] Reentrancy guard where needed?
  - [ ] Return values checked for external calls?
  - [ ] Events emitted for state changes?

**Pass B -- Semantic (intent vs implementation):**
- Does the code do what the documentation says?
- Are there edge cases the developer didn't consider?
- Can function call ordering produce unexpected states?
- Are economic incentives aligned? (game theory)
- What happens during partial failures?
- Are there trust assumptions that could be violated?

### Phase 4: Classification & Reporting

#### Severity definitions

| Severity | Impact | Likelihood | Description |
|----------|--------|------------|-------------|
| Critical | High | High | Direct fund loss, exploitable without special conditions |
| High | High | Medium | Fund loss requiring specific conditions, privilege escalation |
| Medium | Medium | Medium | Limited fund loss, griefing, protocol dysfunction |
| Low | Low | Any | Best practice violations, informational |
| Informational | -- | -- | Gas optimizations, code quality, style |

#### Finding structure

Each finding should include:
1. **Title** -- concise vulnerability name
2. **Severity** -- Critical/High/Medium/Low/Informational
3. **Location** -- file, function, line numbers
4. **Description** -- what's wrong
5. **Impact** -- what an attacker can achieve
6. **Proof of Concept** -- Foundry test demonstrating the exploit
7. **Recommendation** -- how to fix it

## Key principles

- **Assume all external input is malicious** -- users, oracles, other contracts
- **Verify invariants, not individual operations** -- does the property hold after ANY sequence of calls?
- **Think in attack trees** -- what's the attacker's goal? What paths lead there?
- **Check the boundaries** -- zero values, max values, empty arrays, first/last operations
- **Review the tests** -- what isn't tested? That's where bugs hide
