---
title: Live Documentation Sources
impact: MEDIUM
impactDescription: Reference index for supplemental live documentation sources
tags: solidity, ethskills, reference, webfetch
---

# Live Documentation Sources

When local skill content needs supplementation, fetch these URLs for
the latest information. Use WebFetch to retrieve.

## ETHSkills

| Skill | URL | Covers |
|-------|-----|--------|
| Security | `https://ethskills.com/security/SKILL.md` | Vulnerabilities, exploit mechanics, pre-deploy checklist |
| Tools | `https://ethskills.com/tools/SKILL.md` | Foundry, Blockscout MCP, abi.ninja, framework selection |
| L2s | `https://ethskills.com/l2s/SKILL.md` | Cross-chain, bridging, L2 economics |
| Standards | `https://ethskills.com/standards/SKILL.md` | ERC-8004, EIP-7702, token standards |
| Gas | `https://ethskills.com/gas/SKILL.md` | Current gas costs (mainnet, L2s) |

## Community Skills

| Source | URL | Focus |
|--------|-----|-------|
| Trail of Bits | `https://github.com/trailofbits/skills` | 58 skills across security, auditing, RE |
| Pashov | `https://github.com/pashov/skills` | Multi-agent audit orchestration |
| Cyfrin | `https://github.com/Cyfrin/solskill` | Solidity development standards |
| scv-scan | `https://github.com/kadenzipfel/scv-scan` | Dual-pass audit methodology |
| QuillAudits | `https://github.com/quillai-network/qs_skills` | AI-assisted auditing |
| Archethect | `https://github.com/Archethect/sc-auditor` | Smart contract auditor + MCP tools |

## Reference Documentation

| Resource | URL |
|----------|-----|
| Solidity docs | `https://docs.soliditylang.org/` |
| OpenZeppelin contracts | `https://docs.openzeppelin.com/contracts/` |
| Foundry book | `https://book.getfoundry.sh/` |
| Chainlink docs | `https://docs.chain.link/` |
| EIPs | `https://eips.ethereum.org/` |
| Slither wiki | `https://github.com/crytic/slither/wiki` |

## Usage

```
// In Claude Code, fetch latest security skill:
WebFetch("https://ethskills.com/security/SKILL.md")
```
