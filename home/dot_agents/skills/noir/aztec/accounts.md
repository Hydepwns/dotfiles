---
title: Aztec Account Abstraction & Access Control
tags: noir, aztec, accounts, authwit, access-control, keys, signing
---

# Aztec Account Abstraction & Access Control

## Account contract structure

Every Aztec account is a smart contract. There are no externally owned
accounts. An account contract needs two functions: an entrypoint and
a verification function.

INCORRECT:

```noir
contract MyAccount {
    // BUG: no entrypoint -- transactions can't be initiated
    // BUG: no verification -- anyone can act as this account
    #[aztec(private)]
    fn do_something() { /* ... */ }
}
```

CORRECT:

```noir
contract MyAccount {
    use dep::aztec::prelude::*;

    #[aztec(storage)]
    struct Storage {
        public_key: PrivateImmutable<PublicKeyNote>,
    }

    #[aztec(private)]
    fn entrypoint(payload: EntrypointPayload) {
        let actions = AccountActions::private(
            &mut context,
            ACCOUNT_ACTIONS_STORAGE_SLOT,
            is_valid_impl,
        );
        actions.entrypoint(payload);
    }

    fn is_valid_impl(context: &mut PrivateContext, message: Field) -> bool {
        let key = storage.public_key.get_note();
        let witness: [u8; 64] = get_auth_witness(message);
        std::schnorr::verify_signature(
            key.x, key.y, witness, message.to_be_bytes(32),
        )
    }
}
```

`is_valid_impl` returns a boolean, not void. Aztec calls it "witness"
instead of "signature" because verification can use any scheme --
Schnorr, ECDSA, multisig, biometrics, or even permissionless (always true).

## Signing scheme selection

Schnorr is the default. Use ECDSA only when wallet interop is required.

| Scheme | Circuit gates | Use case |
|--------|--------------|----------|
| Schnorr | ~26k | Default, efficient, native |
| ECDSA-k1 | ~40k | MetaMask/Ethereum wallet compat |
| ECDSA-r1 | ~40k | WebAuthn/passkey compat |

ECDSA adds ~14k gates over Schnorr for the same verification. Choose
based on whether you need to interop with existing Ethereum wallets or
WebAuthn passkeys, not as a default.

## Key management: protocol vs signing keys

Aztec uses multiple key types. Protocol keys are immutable and embedded
in the address. Signing keys are application-defined and rotatable.

**Protocol keys (cannot rotate):**
- Nullifier master key (`nhk_m`) -- derives per-app nullifier keys
- Incoming viewing key (`ivsk`) -- decrypts received notes
- These are embedded in the account address at creation

**Signing keys (can rotate):**
- Defined by the account contract's `is_valid_impl`
- Stored in contract storage, changeable by contract logic

INCORRECT:

```noir
// BUG: storing nullifier key in mutable storage -- it's protocol-managed
#[aztec(storage)]
struct Storage {
    nullifier_key: PublicMutable<Field>,  // can't rotate protocol keys
}
```

CORRECT:

```noir
#[aztec(storage)]
struct Storage {
    // Signing key is rotatable -- store in contract storage
    signing_key: SharedMutable<PublicKeyNote, 14400>,
}

#[aztec(public)]
fn rotate_signing_key(new_key: PublicKeyNote) {
    assert(context.msg_sender() == context.this_address(), "self only");
    storage.signing_key.schedule_value_change(new_key);
}
```

If the master nullifier key is compromised, all app-siloed keys are
compromised and there is no recovery -- the user must deploy a new account.

## Access control in private functions

Private functions cannot read public state directly. To check admin
permissions, enqueue a public assertion call.

INCORRECT:

```noir
#[aztec(private)]
fn admin_action() {
    // BUG: can't read PublicMutable from private context
    let admin = storage.admin.read();
    assert(context.msg_sender() == admin);
}
```

CORRECT:

```noir
#[aztec(private)]
fn admin_action() {
    // Do private work...

    // Enqueue public call to verify admin (executes after private)
    Token::at(context.this_address())
        ._assert_is_admin(context.msg_sender())
        .enqueue(&mut context);
}

#[aztec(public)]
#[aztec(internal)]
fn _assert_is_admin(caller: AztecAddress) {
    assert(caller == storage.admin.read(), "not admin");
}
```

The assertion runs in public context after private execution. If it
fails, the entire transaction reverts including private state changes.

## msg_sender across contexts

`msg_sender` behaves consistently but the source differs by context.

| Call type | msg_sender is |
|-----------|---------------|
| Entrypoint | Account contract address |
| Private -> private | Calling contract address |
| Private -> public (enqueue) | Original private caller |
| Public -> public | Calling contract address |

INCORRECT:

```noir
#[aztec(public)]
#[aztec(internal)]
fn _finalize(caller: AztecAddress) {
    // BUG: msg_sender here is this contract (internal call), not the user
    // Don't use msg_sender for user identity in internal public functions
    let user = context.msg_sender();  // wrong -- this is self
}
```

CORRECT:

```noir
#[aztec(private)]
fn initiate() {
    // Pass the actual caller explicitly to the public function
    Token::at(context.this_address())
        ._finalize(context.msg_sender())
        .enqueue(&mut context);
}

#[aztec(public)]
#[aztec(internal)]
fn _finalize(caller: AztecAddress) {
    // Use the explicitly passed caller, not msg_sender
    storage.last_caller.write(caller);
}
```

## Unrestricted verification logic

Unlike ERC-4337 which restricts validation opcodes to prevent mempool
DoS, Aztec verification runs client-side. Expensive operations cost
prover time, not gas.

INCORRECT (ERC-4337 thinking):

```noir
fn is_valid_impl(context: &mut PrivateContext, message: Field) -> bool {
    // Avoiding complex checks to "save gas" -- unnecessary in Aztec
    // Single signature only, no oracle checks, simplified logic
    basic_sig_check(message)
}
```

CORRECT:

```noir
fn is_valid_impl(context: &mut PrivateContext, message: Field) -> bool {
    // Complex verification is fine -- runs client-side, not on-chain
    // Multisig: check k-of-n signers
    let witnesses = get_auth_witnesses(message, NUM_SIGNERS);
    let mut valid_count: u32 = 0;
    for i in 0..NUM_SIGNERS {
        if verify_signer(keys[i], witnesses[i], message) {
            valid_count += 1;
        }
    }
    valid_count >= THRESHOLD
}
```

This enables multisig, oracle-validated auth, and complex access control
without the gas constraints that limit Ethereum account abstraction.
