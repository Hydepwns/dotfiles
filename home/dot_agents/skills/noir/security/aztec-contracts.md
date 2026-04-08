---
title: Aztec Contract Security
tags: noir, aztec, security, nullifiers, front-running, notes, privacy
---

# Aztec Contract Security

## Incomplete nullifier derivation

Nullifiers prevent double-spends. If the derivation omits the note owner
or unique identifier, the same note can produce multiple valid nullifiers.

INCORRECT:

```noir
// BUG: nullifier only uses note content -- same value notes share nullifiers
fn compute_nullifier(note: ValueNote) -> Field {
    std::hash::poseidon::bn254::hash_2([note.value, note.randomness])
}
```

CORRECT:

```noir
fn compute_nullifier(note: ValueNote, context: &mut PrivateContext) -> Field {
    // Include owner's nullifier key (app-siloed) and unique note hash
    let nhk_app = context.request_nsk_app(note.npk_m_hash);
    std::hash::poseidon::bn254::hash_3([
        note.get_note_hash(),  // unique per note
        nhk_app,               // owner-specific, app-siloed
        note.randomness,       // prevents precomputation
    ])
}
```

Nullifier keys are app-siloed: `nhk_app = hash(nhk_m, contract_address)`.
This prevents cross-contract activity correlation, but if the master
nullifier key leaks, all app-siloed keys are compromised with no rotation
mechanism -- the user must deploy a new account.

## Note griefing

Anyone can create notes for arbitrary addresses. Victims must store and
track these notes, and each requires a nullifier to spend. There is no
protocol-level rate limiting.

INCORRECT:

```noir
#[aztec(private)]
fn airdrop(recipient: AztecAddress, amount: u64) {
    // No rate limiting -- attacker can spam thousands of dust notes
    let note = ValueNote::new(amount, recipient);
    storage.balances.at(recipient).insert(&mut note);
}
```

CORRECT:

```noir
#[aztec(private)]
fn airdrop(recipient: AztecAddress, amount: u64) {
    // Enforce minimum note value to make spam expensive
    assert(amount >= MIN_NOTE_VALUE, "amount below dust threshold");

    let note = ValueNote::new(amount, recipient);
    storage.balances.at(recipient).insert(&mut note);
}
```

Design note-consuming functions to consolidate small notes during
normal operations (e.g., merge change notes on transfer).

## Public function front-running

Private functions can enqueue public calls, but the public portion is
visible in the mempool. The sequencer and other observers can front-run.

INCORRECT:

```noir
#[aztec(private)]
fn swap(token_in: AztecAddress, amount: u64, min_out: u64) {
    // Private: burn input tokens (hidden)
    // ...

    // BUG: public call args are visible -- sequencer sees the swap
    // and can sandwich it. min_out=0 makes this trivially exploitable.
    Amm::at(amm_address).execute_swap(token_in, amount, 0).enqueue(&mut context);
}
```

CORRECT:

```noir
#[aztec(private)]
fn swap(token_in: AztecAddress, amount: u64, min_out: u64) {
    // Private: burn input tokens (hidden)
    // ...

    // Enforce slippage in the public call -- sequencer can see args
    // but cannot extract value beyond the slippage tolerance
    assert(min_out > 0, "slippage protection required");
    Amm::at(amm_address).execute_swap(token_in, amount, min_out)
        .enqueue(&mut context);
}
```

All arguments to enqueued public functions are visible. Never pass
sensitive data (amounts, addresses, strategies) to public functions
unless acceptable as public information.

## Private-to-public information leakage

Calling public functions from private context leaks more than just
arguments. The call itself reveals that a private action occurred.

What leaks when private calls public:
- All arguments to the public function
- All L2-to-L1 messages (full content)
- Public logs (topics and arguments)
- The fact that a private function initiated the call

INCORRECT:

```noir
#[aztec(private)]
fn private_transfer(to: AztecAddress, amount: u64) {
    // Transfer notes privately... then:

    // BUG: emitting an unencrypted event from private context
    // reveals sender, recipient, and amount publicly
    context.emit_unencrypted_log(Transfer { from: context.msg_sender(), to, amount });
}
```

CORRECT:

```noir
#[aztec(private)]
fn private_transfer(to: AztecAddress, amount: u64) {
    // Transfer notes privately... then:

    // Use encrypted events -- only sender and recipient can decrypt
    context.emit_private_log(
        Transfer { from: context.msg_sender(), to, amount }
    );
}
```

## SharedMutable unsafe delays

SharedMutable enables both private and public reads with scheduled
value changes. A minimal delay gives users no time to react.

INCORRECT:

```noir
#[aztec(storage)]
struct Storage {
    // BUG: 1 block delay (~12s) -- users can't exit before change takes effect
    fee_rate: SharedMutable<u64, 1>,
    admin: SharedMutable<AztecAddress, 1>,
}

#[aztec(public)]
fn change_fee(new_fee: u64) {
    assert(context.msg_sender() == storage.admin.read(), "not admin");
    storage.fee_rate.schedule_value_change(new_fee);
}
```

CORRECT:

```noir
#[aztec(storage)]
struct Storage {
    // Governance-safe delay: ~2 days in blocks (14400 blocks at 12s)
    fee_rate: SharedMutable<u64, 14400>,
    admin: SharedMutable<AztecAddress, 14400>,
}

#[aztec(public)]
fn change_fee(new_fee: u64) {
    assert(context.msg_sender() == storage.admin.read(), "not admin");
    // Users have ~2 days to review and exit if they disagree
    storage.fee_rate.schedule_value_change(new_fee);
}
```

Never directly write to SharedMutable's underlying storage slots --
use `schedule_value_change()` exclusively or all safety properties break.

## PXE query privacy leakage

When the PXE queries a node for state (nullifier existence, note
membership), the node learns which data the user is interested in.

This is not a code-level bug but an architectural concern:
- Node operators can correlate queries to user IP addresses
- Nullifier existence checks reveal which notes a user might own
- Repeated queries for the same state are linkable

Mitigation: users running their own Aztec node eliminates this vector.
For high-privacy applications, document this limitation for users.
