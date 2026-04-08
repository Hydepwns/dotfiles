---
title: Aztec E2E Token & AuthWit Testing
impact: HIGH
impactDescription: AuthWit and transfer test errors hide replay attacks and balance inconsistencies.
tags: noir, aztec, e2e, testing, token, authwit, transfer, minting
---

# Aztec E2E Token & AuthWit Testing

## Reading private balances

Private balances are note-based -- the `from` parameter scopes which
notes are visible. Omitting it returns the wrong viewer's balance or zero.

INCORRECT:

```typescript
// BUG: no from scope -- reads from default wallet, not the target address
const balance = await token.methods.balance_of_private(otherAddress).simulate();
```

CORRECT:

```typescript
// from scopes note visibility to the correct owner
const balance = await token.methods
  .balance_of_private(ownerAddress)
  .simulate({ from: ownerAddress });
```

For public balances, `from` is not needed since state is unencrypted:

```typescript
const publicBalance = await token.methods
  .balance_of_public(address)
  .simulate();
```

## Transfer patterns

Three transfer types exist. Using the wrong method for the context is
a common source of silent failures.

| Operation | Method | Notes |
|-----------|--------|-------|
| Private to private | `transfer(to, amount)` | Consumes sender notes, creates recipient notes |
| Public to public | `transfer_public(from, to, amount, nonce)` | Direct state mutation |
| Private to public | `transfer_to_public(to, amount)` | Burns notes, credits public balance |
| Public to private | `transfer_to_private(to, amount)` | Debits public, creates notes |

INCORRECT:

```typescript
// BUG: using private transfer for public balance
await token.methods.transfer(recipient, amount).send().wait();
// Sender's public balance unchanged -- notes were consumed instead
```

CORRECT:

```typescript
// Public transfer explicitly targets public state
await token.methods
  .transfer_public(sender, recipient, amount, 0n)
  .send()
  .wait();
```

## Minting batch limits

Private minting creates notes. Aztec limits notes created per transaction
(typically 5). Minting large amounts requires multiple transactions.

INCORRECT:

```typescript
// BUG: tries to mint 1000 tokens in one note -- may exceed limits
await token.methods.mint_to_private(recipient, 1000n).send().wait();
```

CORRECT:

```typescript
// Helper respects batch limits, splits across txs if needed
await mintTokensToPrivate(token, wallet, recipient, 1000n);

// Or manually batch:
const batchSize = 5n;
for (let i = 0n; i < totalNotes; i += batchSize) {
  const amount = i + batchSize > totalNotes ? totalNotes - i : batchSize;
  await token.methods.mint_to_private(recipient, amount).send().wait();
}
```

## AuthWit nonce rules

Authorization witnesses delegate actions. The nonce prevents replay.
Self-initiated actions use nonce=0; delegated actions MUST use a random
nonce or the authwit is replayable.

INCORRECT:

```typescript
// BUG: nonce=0 for delegated transfer -- anyone can replay this
const action = token.methods.transfer_public(owner, recipient, amount, 0n);
const witness = await ownerWallet.createAuthWit({
  caller: spenderAddress,
  action,
});
```

CORRECT:

```typescript
// Random nonce for delegated actions prevents replay
const nonce = Fr.random();
const action = token.methods.transfer_public(owner, recipient, amount, nonce);
const witness = await ownerWallet.createAuthWit({
  caller: spenderAddress,
  action,
});
await spenderWallet.addAuthWitness(witness);
```

Self-initiated transfers (msg_sender == from) use nonce=0:

```typescript
// Self-transfer: nonce MUST be zero
await token.methods.transfer_public(myAddress, recipient, amount, 0n)
  .send()
  .wait();
```

## AuthWit private vs public

Private and public authwits use different APIs. A private authwit won't
work in a public context and vice versa.

INCORRECT:

```typescript
// BUG: createAuthWit is for private -- won't work in public context
const witness = await wallet.createAuthWit({ caller, action });
// Then calling a public function that checks authorization...
await contract.methods.public_transfer_from(owner, to, amount).send().wait();
// Fails: no public authorization found
```

CORRECT:

```typescript
// Private context: createAuthWit + addAuthWitness
const witness = await ownerWallet.createAuthWit({ caller, action });
await callerWallet.addAuthWitness(witness);

// Public context: setPublicAuthWit (registers on-chain)
await ownerWallet.setPublicAuthWit({ caller, action }, true).send().wait();
```

Cancel an authwit by emitting a nullifier (prevents future use):

```typescript
await ownerWallet.cancelAuthWit({ caller, action }).send().wait();
// Further attempts to use this authwit will hit DUPLICATE_NULLIFIER_ERROR
```

## Error pattern testing

Use specific error patterns, not generic catch-alls. Aztec errors have
consistent formats.

INCORRECT:

```typescript
// Too broad -- masks real failures
await expect(operation()).rejects.toThrow();
```

CORRECT:

```typescript
// Specific error patterns
await expect(
  token.methods.transfer(to, excessiveAmount).send().wait()
).rejects.toThrow(/Balance too low/);

await expect(
  replayedAuthwitAction.send().wait()
).rejects.toThrow(/DUPLICATE_NULLIFIER_ERROR/);

await expect(
  unauthorizedAction.send().wait()
).rejects.toThrow(/Unknown auth witness/);
```

Common error patterns:

| Error | Cause |
|-------|-------|
| `DUPLICATE_NULLIFIER_ERROR` | Double-spend, replayed authwit, re-consumed note |
| `Balance too low` | Transfer/burn exceeds available balance |
| `Unknown auth witness` | Missing or wrong authwit for delegated action |
| `Arithmetic overflow` | u128/u64 operation exceeded type bounds |
| `Not initialized` | Calling init-checked function before initializer |
