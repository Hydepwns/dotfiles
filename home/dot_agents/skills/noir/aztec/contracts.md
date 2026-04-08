---
title: Aztec Contract Patterns
impact: HIGH
impactDescription: Wrong contract structure or note handling causes silent state corruption in private execution.
tags: noir, aztec, private-functions, public-functions, notes, storage
---

# Aztec Contract Patterns

## Contract structure

Aztec contracts use Noir with the `aztec` macro library. Functions are
annotated as private (executed client-side, proven in ZK) or public
(executed by the sequencer, visible on-chain).

INCORRECT:

```noir
// No annotations -- unclear execution context
contract Token {
    fn transfer(from: Field, to: Field, amount: u64) {
        // Is this private or public? Who executes it?
    }
}
```

CORRECT:

```noir
contract Token {
    use dep::aztec::prelude::{
        AztecAddress, FunctionSelector, NoteHeader, PrivateContext, PublicContext,
    };

    #[aztec(storage)]
    struct Storage {
        balances: Map<AztecAddress, PrivateSet<ValueNote>>,
        total_supply: PublicMutable<u64>,
    }

    #[aztec(private)]
    fn transfer(to: AztecAddress, amount: u64) {
        // Runs client-side, generates a proof
        // msg_sender() is authenticated via private key
        let from = context.msg_sender();
        // ... spend notes, create new notes
    }

    #[aztec(public)]
    fn mint_public(to: AztecAddress, amount: u64) {
        // Runs on sequencer, visible on-chain
        // Access control via public state
        let supply = storage.total_supply.read();
        storage.total_supply.write(supply + amount);
    }
}
```

## Private state: notes

Private state is stored as "notes" -- encrypted data that only the owner
can read. Notes are created, consumed (nullified), and never updated in-place.

INCORRECT:

```noir
#[aztec(private)]
fn transfer(to: AztecAddress, amount: u64) {
    // BUG: can't "update" private state -- notes are immutable
    let mut balance = storage.balances.at(context.msg_sender()).read();
    balance -= amount;
    storage.balances.at(context.msg_sender()).write(balance);
}
```

CORRECT:

```noir
#[aztec(private)]
fn transfer(to: AztecAddress, amount: u64) {
    // 1. Get notes with enough value (consumes/nullifies them)
    let notes = storage.balances.at(context.msg_sender()).get_notes(
        NoteGetterOptions::new()
    );

    // 2. Sum up note values, verify >= amount
    let mut sum: u64 = 0;
    for note in notes {
        sum += note.value;
    }
    assert(sum >= amount, "insufficient balance");

    // 3. Create new note for recipient
    let to_note = ValueNote::new(amount, to);
    storage.balances.at(to).insert(&mut to_note);

    // 4. Create change note for sender (if any)
    let change = sum - amount;
    if change > 0 {
        let change_note = ValueNote::new(change, context.msg_sender());
        storage.balances.at(context.msg_sender()).insert(&mut change_note);
    }
}
```

## Public-private composition

Private functions can enqueue public function calls (private -> public).
Public functions CANNOT call private functions (public -> private is impossible
because private execution requires the user's key).

INCORRECT:

```noir
#[aztec(public)]
fn settle(user: AztecAddress, amount: u64) {
    // BUG: can't call private from public
    context.call_private_function(
        context.this_address(),
        FunctionSelector::from_signature("spend_notes(AztecAddress,u64)"),
        [user.to_field(), amount as Field],
    );
}
```

CORRECT:

```noir
#[aztec(private)]
fn shield(amount: u64) {
    // Private: consume public balance, create private note
    // Enqueue a public call to deduct from public balance
    context.call_public_function(
        context.this_address(),
        FunctionSelector::from_signature("deduct_public(AztecAddress,u64)"),
        [context.msg_sender().to_field(), amount as Field],
    );

    // Create private note for the caller
    let note = ValueNote::new(amount, context.msg_sender());
    storage.balances.at(context.msg_sender()).insert(&mut note);
}

#[aztec(public)]
#[aztec(internal)]
fn deduct_public(from: AztecAddress, amount: u64) {
    // Only callable by this contract (internal)
    let balance = storage.public_balances.at(from).read();
    assert(balance >= amount, "insufficient public balance");
    storage.public_balances.at(from).write(balance - amount);
}
```

## Storage patterns

| Type | Visibility | Mutability | Use case |
|------|-----------|------------|----------|
| `PrivateSet<Note>` | Private | Append/nullify | Token balances, credentials |
| `PrivateImmutable<Note>` | Private | Write-once | Identity, permanent records |
| `PublicMutable<T>` | Public | Read/write | Total supply, admin address |
| `PublicImmutable<T>` | Public | Write-once | Contract parameters |
| `SharedImmutable<T>` | Both | Write-once | Cross-context constants |
| `Map<K, V>` | Either | Per-value | Per-user storage |
