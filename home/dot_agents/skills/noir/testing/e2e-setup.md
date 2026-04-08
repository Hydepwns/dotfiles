---
title: Aztec E2E Test Setup
tags: noir, aztec, e2e, testing, setup, deployment, accounts
---

# Aztec E2E Test Setup

## Test lifecycle with setup/teardown

The `setup()` function orchestrates Anvil (L1), Aztec node, PXE, and
pre-funded accounts. Manual wiring is error-prone and leaks resources.

INCORRECT:

```typescript
// Manual setup -- verbose, fragile, resource leaks
let node: AztecNode;
let pxe: PXE;

beforeAll(async () => {
  node = await AztecNode.createAndSync(config);
  pxe = await createPXEService(node);
  const wallet = await createAccount(pxe);
  // Forgot to fund accounts, no teardown, no L1...
});
```

CORRECT:

```typescript
let teardown: () => Promise<void>;
let wallets: AccountWallet[];
let aztecNode: AztecNode;

beforeAll(async () => {
  // setup(n) returns n pre-funded wallets, node, PXE, cheat codes
  ({ wallets, aztecNode, teardown } = await setup(2));
});

afterAll(() => teardown());
```

The `numAccounts` parameter controls how many Schnorr-signed wallets
are deployed and funded. Use the minimum needed -- each adds setup time.

## Account deployment for public access

Accounts exist privately by default. Public function calls fail with
opaque errors if the account contract is not publicly deployed.

INCORRECT:

```typescript
const { wallets } = await setup(2);
// BUG: wallets are only privately deployed
// Public function calls from these wallets will fail
await token.methods.mint_public(wallets[0].getAddress(), 100n).send().wait();
```

CORRECT:

```typescript
const { wallets } = await setup(2);
// Publicly deploy accounts BEFORE any public function calls
await publicDeployAccounts(wallets[0], wallets.slice(0, 2));

await token.methods.mint_public(wallets[0].getAddress(), 100n).send().wait();
```

Call `publicDeployAccounts()` once after `setup()` if any test uses
public functions. The first argument is the sender wallet that pays fees.

## Contract deployment patterns

Always await the full deploy-send-deployed chain. Calling methods on a
contract before deployment is confirmed leads to silent failures.

INCORRECT:

```typescript
// Missing .deployed() -- contract may not be ready
const token = await TokenContract.deploy(wallet, admin, 'Test', 'TST', 18n)
  .send();
// Calling methods before deployment is confirmed
await token.methods.mint_public(admin, 1000n).send().wait();
```

CORRECT:

```typescript
const token = await TokenContract.deploy(wallet, admin, 'Test', 'TST', 18n)
  .send()
  .deployed();

// Contract is now confirmed on-chain
await token.methods.mint_public(admin, 1000n).send().wait();
```

For deterministic addresses across environments, use universal deploy:

```typescript
const token = await TokenContract.deploy(wallet, admin, 'Test', 'TST', 18n)
  .send({ universalDeploy: true })
  .deployed();
```

Init-checked functions revert if called before the initializer completes.
The public init nullifier is emitted at the end of the initializer, so
external callers cannot interact with a half-initialized contract.

## State verification helpers

Raw assertions are repetitive and produce unreadable failures. Use
mapping helpers to assert state across multiple accounts at once.

INCORRECT:

```typescript
// Manual assertions -- verbose, poor failure messages
const b1 = await token.methods.balance_of_public(addr1).simulate();
const b2 = await token.methods.balance_of_public(addr2).simulate();
expect(b1).toBe(900n);
expect(b2).toBe(100n);
```

CORRECT:

```typescript
// Declarative: accounts + expected values in one call
await expectMapping(
  token.methods.balance_of_public,
  [addr1, addr2],
  [900n, 100n],
);

// For change-based assertions after an operation:
await expectMappingDelta(
  token.methods.balance_of_public,
  [addr1, addr2],
  [-100n, +100n],  // deltas from previous state
);
```

## Waiting for chain state

`send().wait()` confirms the tx is mined, NOT that it is proven.
Cross-chain tests and epoch-boundary tests need proven finality.

INCORRECT:

```typescript
await token.methods.transfer(to, amount).send().wait();
// BUG: assumes proven immediately -- L2->L1 message not yet available
await l1Portal.withdraw(amount);
```

CORRECT:

```typescript
const receipt = await token.methods.transfer(to, amount).send().wait();
// Wait for the block to be proven before relying on finality
await waitForProvenChain(aztecNode, receipt.blockNumber!);
```
