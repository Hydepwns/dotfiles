---
title: Aztec E2E Cross-Chain & Events
impact: HIGH
impactDescription: Cross-chain message timing errors cause stuck funds or silent withdrawal failures.
tags: noir, aztec, e2e, testing, l1, l2, messaging, events, cross-chain
---

# Aztec E2E Cross-Chain & Events

## CrossChainTestHarness setup

The harness deploys and wires L1 token portals, L2 token contracts, and
bridge contracts. Manual wiring is error-prone due to address mismatches
between L1 and L2 contracts.

INCORRECT:

```typescript
// Manual portal wiring -- easy to mismatch addresses
const l1Token = await deployL1Token();
const l1Portal = await deployPortal(l1Token.address);
const l2Token = await TokenContract.deploy(wallet, admin).send().deployed();
// BUG: forgot to register l1Portal address with l2Token
// BUG: forgot to register l2Token address with l1Portal
```

CORRECT:

```typescript
// Harness handles bidirectional address registration
const harness = await CrossChainTestHarness.new(
  aztecNode,
  pxeService,
  publicClient,      // L1 viem client
  walletClient,      // L1 wallet
  wallet,            // L2 wallet
  l1ContractAddresses,
);

// All contracts deployed and cross-registered
const { l2Token, l1Portal, l1Token } = harness;
```

## L1 to L2 message flow

Messages go through a lifecycle: send on L1, fetched by rollup, made
ready at checkpoint, consumed on L2. Consuming before readiness fails
silently or reverts.

INCORRECT:

```typescript
// BUG: consuming immediately after L1 send -- message not yet available
await harness.mintTokensOnL1(amount);
await harness.sendTokensToPortalPublic(l2Recipient, amount, secretHash);
// Message hasn't been fetched by the rollup yet
await harness.consumeMessageOnAztecAndMintPublicly(l2Recipient, amount, secret);
```

CORRECT:

```typescript
await harness.mintTokensOnL1(amount);
const { messageHash } = await harness.sendTokensToPortalPublic(
  l2Recipient, amount, secretHash,
);

// Wait for rollup to fetch and process the message
await harness.makeMessageConsumable(messageHash);

// Now safe to consume on L2
await harness.consumeMessageOnAztecAndMintPublicly(l2Recipient, amount, secret);

// Verify L2 balance
const balance = await harness.getL2PublicBalanceOf(l2Recipient);
expect(balance).toBe(amount);
```

The secret/secretHash pattern: L1 posts `secretHash` (public), L2
consumer proves knowledge of `secret` (private). This prevents front-running.

## L2 to L1 withdrawal

L2-to-L1 messages require a checkpoint advancement before they are
available on L1. Without this, the L1 withdrawal reverts.

INCORRECT:

```typescript
// BUG: withdrawing on L1 immediately after L2 burn
await harness.withdrawPublicFromAztecToL1(l2Address, l1Address, amount);
// Checkpoint not advanced -- message not yet in L1 outbox
const l1Balance = await harness.getL1BalanceOf(l1Address);
// l1Balance is still 0
```

CORRECT:

```typescript
await harness.withdrawPublicFromAztecToL1(l2Address, l1Address, amount);

// Advance checkpoint so L2 message appears in L1 outbox
await harness.advanceCheckpoint();

// Now the L1 portal can process the withdrawal
await harness.claimWithdrawalOnL1(l1Address, amount);

const l1Balance = await harness.getL1BalanceOf(l1Address);
expect(l1Balance).toBe(amount);
```

`advanceCheckpoint()` polls until the checkpoint number increments,
handling the gap between proven blocks and the inbox state.

## Private event testing

Private events are encrypted and scoped to specific viewers. Querying
without the correct scope returns empty results.

INCORRECT:

```typescript
// BUG: no scopes -- can't decrypt private events
const events = await wallet.getPrivateEvents(
  TokenContract.events.Transfer,
  { contractAddress: token.address, fromBlock: 1 },
);
// events is empty even though transfers happened
```

CORRECT:

```typescript
const events = await wallet.getPrivateEvents(
  TokenContract.events.Transfer,
  {
    contractAddress: token.address,
    fromBlock: startBlock,
    toBlock: endBlock + 1,  // toBlock is exclusive
    scopes: [senderAddress, recipientAddress],
  },
);

expect(events).toHaveLength(1);
expect(events[0].data.amount).toBe(transferAmount);
```

The `scopes` array determines which viewer keys are tried for decryption.
Include all addresses that should be able to see the event.

## Public event testing

Public events are unencrypted and globally visible. Use the generated
event schema for type-safe access.

INCORRECT:

```typescript
// Raw log parsing -- fragile, no type safety
const logs = await aztecNode.getLogs(startBlock, endBlock);
const amount = logs[0].data[2];  // index-based, breaks if fields change
```

CORRECT:

```typescript
const { events } = await getPublicEvents(
  aztecNode,
  TokenContract.events.PublicTransfer,
  {
    contractAddress: token.address,
    fromBlock: startBlock,
    toBlock: endBlock + 1,
  },
);

expect(events).toHaveLength(1);
// Type-safe field access via generated schema
expect(events[0].data.from).toEqual(senderAddress);
expect(events[0].data.to).toEqual(recipientAddress);
expect(events[0].data.amount).toBe(amount);
```
