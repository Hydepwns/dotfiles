---
name: ethskills
description: >
  Ethereum ecosystem tooling and standards reference. TRIGGER when: asking
  about Ethereum development tools, framework selection, RPC providers, block
  explorers, EIP/ERC standards, or general Web3 development workflow. DO NOT
  TRIGGER when: writing or auditing Solidity code (use solidity-audit skill),
  or working with Noir/ZK circuits (use noir skill).
metadata:
  author: hydepwns
  version: "1.0.0"
  tags: ethereum, web3, foundry, blockscout, eip, erc, tooling
---

# ethskills

Ethereum ecosystem tooling, framework selection, and standards reference.
For Solidity code and auditing, use solidity-audit. For ZK/Noir, use noir.

## When to use

This skill activates for ecosystem-level questions: which tools to use,
how to configure infrastructure, which standards apply, where to find
resources.

## When NOT to use

- For Solidity code or security auditing -- use solidity-audit
- For Noir/ZK circuit design -- use noir
- For non-Ethereum languages -- use droo-stack

## Reading guide

| Question | Read |
|----------|------|
| Foundry commands, Blockscout MCP, abi.ninja | [tools](tools.md) |
| Foundry vs Hardhat vs Scaffold-ETH 2 | [stack-selection](stack-selection.md) |
| RPC providers, block explorers, faucets | [rpc-explorers](rpc-explorers.md) |
| EIP/ERC standards reference | [standards](standards.md) |
