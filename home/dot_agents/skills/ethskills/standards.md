---
title: EIP & ERC Standards Reference
impact: CRITICAL
impactDescription: Incorrect standard usage causes incompatible or insecure contracts.
tags: ethereum, eip, erc, standards, tokens
---

# EIP & ERC Standards Reference

## Token standards

| Standard | Type | Key features |
|----------|------|-------------|
| ERC-20 | Fungible token | `transfer`, `approve`, `transferFrom` |
| ERC-721 | NFT | `ownerOf`, `safeTransferFrom`, unique token IDs |
| ERC-1155 | Multi-token | Batch transfers, fungible + non-fungible in one contract |
| ERC-4626 | Tokenized vault | Standardized yield-bearing vault interface |
| ERC-2612 | Permit | Gasless approvals via EIP-712 signatures |

## Account abstraction

**EIP-7702** (Pectra upgrade, 2025):
- EOAs can temporarily delegate to smart contract code
- New transaction type (`0x04`) with `authorization_list`
- EOA sets its code to a proxy, gaining smart account features
- Revocable: set delegation to `address(0)` to revert

```solidity
// EIP-7702 authorization
struct Authorization {
    uint256 chainId;
    address codeAddress;  // contract to delegate to
    uint256 nonce;
}
// Signed by the EOA, included in a special transaction
```

**ERC-4337** (Account abstraction without protocol changes):
- Smart contract wallets with `UserOperation` mempool
- Bundlers submit operations, paymasters sponsor gas
- EntryPoint contract validates and executes

## Governance & permissions

| Standard | Purpose |
|----------|---------|
| ERC-5267 | EIP-712 domain discovery |
| EIP-712 | Typed structured data signing |
| ERC-1271 | Contract signature validation (`isValidSignature`) |
| ERC-2771 | Meta-transactions (trusted forwarder) |

## DeFi primitives

| Standard | Purpose |
|----------|---------|
| ERC-4626 | Tokenized vault (deposit/withdraw/mint/redeem) |
| ERC-3156 | Flash loans (standard interface) |
| ERC-7540 | Async tokenized vaults (for RWA, queued redemptions) |

## Recent & emerging

| Standard | Status | Purpose |
|----------|--------|---------|
| ERC-8004 | Draft | Native asset representation |
| EIP-7702 | Final (Pectra) | EOA code delegation |
| ERC-7579 | Draft | Modular smart accounts |
| EIP-7251 | Final (Pectra) | Max effective balance increase (validators) |
| EIP-7691 | Final (Pectra) | Blob throughput increase |

## EIP-712 typed data signing

Standard for signing structured data (used in permits, governance, meta-tx):

```solidity
bytes32 constant DOMAIN_TYPEHASH = keccak256(
    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
);

bytes32 constant PERMIT_TYPEHASH = keccak256(
    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
);

function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v, bytes32 r, bytes32 s
) external {
    if (block.timestamp > deadline) revert ExpiredDeadline();

    bytes32 structHash = keccak256(abi.encode(
        PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline
    ));
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash));
    address signer = ecrecover(digest, v, r, s);

    if (signer != owner) revert InvalidSignature();
    _approve(owner, spender, value);
}
```
