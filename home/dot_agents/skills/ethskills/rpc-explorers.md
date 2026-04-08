---
title: RPC Providers & Block Explorers
impact: MEDIUM
impactDescription: Reference for provider selection, explorer URLs, and verification.
tags: ethereum, rpc, explorer, testnet, faucet
---

# RPC Providers & Block Explorers

## RPC providers

| Provider | Free tier | Chains | Notes |
|----------|-----------|--------|-------|
| Alchemy | 300M compute/mo | 30+ | Best dashboard, webhooks |
| Infura | 100k req/day | 10+ | MetaMask default |
| QuickNode | 10M credits/mo | 25+ | Fastest, add-ons |
| Ankr | 30 req/s | 40+ | No signup needed for public |
| dRPC | 50M req/mo | 50+ | Decentralized, failover |
| Tenderly | 25M req/mo | 20+ | Built-in debugger, simulations |

**For development:** Ankr public endpoints require no API key.

**For production:** Alchemy or QuickNode with dedicated endpoints.

**For testing:** Use `anvil` (Foundry's local node) for unit tests,
fork a real RPC for integration tests.

```bash
# Local development node
anvil

# Fork mainnet locally
anvil --fork-url $ETH_RPC_URL --fork-block-number 18000000
```

## Block explorers by network

| Network | Explorer | API |
|---------|----------|-----|
| Ethereum | etherscan.io | api.etherscan.io |
| Polygon | polygonscan.com | api.polygonscan.com |
| Arbitrum | arbiscan.io | api.arbiscan.io |
| Optimism | optimistic.etherscan.io | api-optimistic.etherscan.io |
| Base | basescan.org | api.basescan.org |
| zkSync | era.zksync.network | block-explorer-api.mainnet.zksync.io |
| Scroll | scrollscan.com | api.scrollscan.com |
| Gnosis | gnosisscan.io | api.gnosisscan.io |

**Blockscout instances** (open-source alternative):
- Available for most networks at `{network}.blockscout.com`
- Use via MCP: `get_address_info(chain_id=X, address="0x...")`

## Testnet faucets

| Network | Faucet |
|---------|--------|
| Sepolia | `sepoliafaucet.com` (Alchemy), `faucets.chain.link` |
| Holesky | `holesky-faucet.pk910.de` (PoW mining) |
| Base Sepolia | `faucet.quicknode.com/base/sepolia` |
| Arbitrum Sepolia | `faucet.quicknode.com/arbitrum/sepolia` |
| OP Sepolia | `faucet.quicknode.com/optimism/sepolia` |

## Verify contracts

```bash
# Foundry -- verify on Etherscan-compatible explorer
forge verify-contract $ADDRESS src/Contract.sol:Contract \
  --chain-id 1 \
  --etherscan-api-key $ETHERSCAN_KEY

# Verify during deployment
forge script script/Deploy.s.sol \
  --rpc-url $RPC \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_KEY
```
