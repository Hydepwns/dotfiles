---
title: Audit Report Template
tags: solidity, audit, report, template
---

# Audit Report Template

## Finding format

Use this template for each finding in an audit report:

```markdown
## [S-N] Title

**Severity:** Critical | High | Medium | Low | Informational

**Location:** `src/Contract.sol#L42-L58`

### Description

[What is the vulnerability? 2-3 sentences max.]

### Impact

[What can an attacker achieve? Quantify if possible: "drain all ETH from the vault",
"inflate token price by 10x", "grief depositors by reverting withdrawals".]

### Proof of Concept

[Foundry test that demonstrates the exploit.]

```solidity
function test_exploit() public {
    // Setup
    // ...

    // Attack
    // ...

    // Verify impact
    assertGt(attacker.balance, initialBalance);
}
```

### Recommendation

[How to fix. Show the corrected code if possible.]

```solidity
// Fix: add reentrancy guard and follow CEI
function withdraw(uint256 amount) external nonReentrant {
    balances[msg.sender] -= amount;
    (bool success,) = msg.sender.call{value: amount}("");
    if (!success) revert TransferFailed();
}
```
```

## Report structure

```markdown
# Security Audit Report: [Protocol Name]

## Overview

| Item | Detail |
|------|--------|
| Client | [Name] |
| Repository | [URL] |
| Commit | [hash] |
| Scope | [files/contracts in scope] |
| Methods | Manual review, Slither, Foundry fuzzing |
| Date | [date range] |

## Summary of Findings

| ID | Title | Severity | Status |
|----|-------|----------|--------|
| C-1 | [title] | Critical | [Open/Fixed/Acknowledged] |
| H-1 | [title] | High | [Open/Fixed/Acknowledged] |
| M-1 | [title] | Medium | [Open/Fixed/Acknowledged] |

## Findings

[Individual findings using the template above]

## Appendix

### Scope

[List of files reviewed with line counts]

### Tools

- Slither v[version]
- Foundry v[version]
- Mythril v[version] (if used)

### Disclaimer

[Standard disclaimer about point-in-time review, no guarantee of
completeness, etc.]
```
