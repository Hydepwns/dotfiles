---
name: solidity-audit
description: >
  Solidity development standards and security auditing. TRIGGER when: working
  with .sol files, foundry.toml, hardhat.config.*, smart contract auditing,
  security review, or vulnerability analysis. Covers Foundry-first development
  patterns, vulnerability taxonomies, and audit methodology. DO NOT TRIGGER
  when: general Ethereum tooling/ecosystem questions (use ethskills skill),
  or Noir/ZK circuits (use noir skill).
metadata:
  author: hydepwns
  version: "1.0.0"
  tags: solidity, audit, security, foundry, smart-contracts, vulnerabilities
---

# solidity-audit

Opinionated Solidity development standards and security auditing methodology.
Foundry-first. Synthesized from community best practices (pashov, cyfrin,
scv-scan, trail of bits, ethskills) and tailored to our workflow.

## Philosophy

Everything will be attacked. Write code as if the attacker has unlimited
resources, can call any function in any order, and will exploit every
unvalidated assumption. Prove safety through invariant testing, not
optimistic unit tests.

## When to use

This skill activates when writing, reviewing, or auditing Solidity contracts.

## When NOT to use

- For general Ethereum ecosystem/tooling -- use ethskills
- For Noir/ZK circuit work -- use noir
- For non-Solidity languages -- use droo-stack

## See also

- `ethskills` -- for EIP/ERC standard lookup, tool selection, and RPC/explorer reference
- `noir` -- for ZK circuits that integrate with Solidity via verifier contracts
- `design-ux` -- for smart contract frontend design and transaction UX

## Reading guide

### Development patterns

| Working on | Read |
|-----------|------|
| Code quality, NatSpec, errors, events, gas | [patterns/standards](patterns/standards.md) |
| Foundry testing, fuzzing, invariants, forks | [patterns/foundry](patterns/foundry.md) |

### Vulnerability knowledge (by severity)

| Category | Read |
|----------|------|
| Reentrancy (classic, cross-function, read-only) | [vulnerabilities/reentrancy](vulnerabilities/reentrancy.md) |
| Access control, tx.origin, delegatecall | [vulnerabilities/access-control](vulnerabilities/access-control.md) |
| Oracle manipulation, Chainlink, TWAP | [vulnerabilities/oracle-manipulation](vulnerabilities/oracle-manipulation.md) |
| Flash loan price/governance attacks | [vulnerabilities/flash-loans](vulnerabilities/flash-loans.md) |
| MEV, frontrunning, sandwich protection | [vulnerabilities/mev](vulnerabilities/mev.md) |

### Audit workflow

| Task | Read |
|------|------|
| Full audit methodology (4 phases) | [audit-workflow/methodology](audit-workflow/methodology.md) |
| Finding report template | [audit-workflow/report-template](audit-workflow/report-template.md) |
| Live documentation sources (ETHSkills, etc.) | [live-sources](live-sources.md) |
