---
title: Framework & Stack Selection
tags: ethereum, foundry, hardhat, scaffold-eth, framework
---

# Framework & Stack Selection

## Decision matrix

| Factor | Foundry | Hardhat | Scaffold-ETH 2 |
|--------|---------|---------|-----------------|
| Language | Solidity (tests too) | JavaScript/TypeScript | TypeScript + Solidity |
| Speed | Fast (Rust) | Slower (Node.js) | Depends on underlying |
| Fuzzing | Built-in | Plugin (echidna) | Via Foundry/Hardhat |
| Fork testing | Built-in | Built-in | Via underlying |
| Debugger | `forge debug` | `console.log` + Tenderly | Depends |
| Frontend | None | None | Next.js + wagmi + viem |
| Best for | Protocol development, auditing | DApp backends, migrations | Full-stack prototypes |
| Learning curve | Medium (Solidity tests) | Low (JS familiarity) | Low (scaffolded) |

## When to use Foundry (default choice)

- Writing and auditing smart contracts
- Fuzz testing and invariant testing
- Gas optimization
- Protocol development
- Any project where tests should be in Solidity

```bash
forge init my-protocol
forge install OpenZeppelin/openzeppelin-contracts
```

## When to use Hardhat

- Complex deployment/migration scripts in TypeScript
- Projects with heavy JavaScript tooling integration
- When team is JS-native and won't write Solidity tests
- Legacy projects already using Hardhat

## When to use Scaffold-ETH 2

- Rapid prototyping with frontend
- Hackathon projects
- Learning / teaching
- When you need a working UI fast

```bash
npx create-eth@latest
```

## Hybrid approach

Many production projects use Foundry for contracts + testing and a
separate frontend framework (Next.js, Vite) with viem/wagmi for the UI.
This gives the best of both worlds.

```
project/
  contracts/          # Foundry project
    src/
    test/
    foundry.toml
  frontend/           # Next.js + wagmi
    src/
    package.json
```
