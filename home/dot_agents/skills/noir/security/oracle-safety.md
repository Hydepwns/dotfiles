---
title: Oracle Safety
tags: noir, oracle, unconstrained, safety, verification
---

# Oracle Safety

## The fundamental oracle rule

An oracle runs outside the circuit. The prover controls it completely.
**Every oracle return value must be constrained before use.**

INCORRECT:

```noir
#[oracle(get_balance)]
unconstrained fn oracle_balance(account: Field) -> u64 {}

fn main(account: Field, min_balance: pub u64) {
    let balance = oracle_balance(account);
    // BUG: prover can return any balance they want
    assert(balance >= min_balance, "insufficient balance");
}
```

CORRECT:

```noir
fn main(
    account: Field,
    min_balance: pub u64,
    balance: pub u64,           // balance is PUBLIC -- verified on-chain
    state_root: pub Field,       // anchors to blockchain state
    merkle_proof: [Field; 32],   // proves balance exists in state
    proof_indices: [u1; 32],
) {
    // Verify the balance is genuinely in the state tree
    let leaf = std::hash::poseidon::bn254::hash_2([account, balance as Field]);
    verify_merkle(leaf, merkle_proof, proof_indices, state_root);
    assert(balance >= min_balance, "insufficient balance");
}
```

## Constrain ALL unconstrained outputs

If an unconstrained function returns multiple values, constrain every one.
A single unconstrained value poisons all downstream computation.

INCORRECT:

```noir
unconstrained fn decompose_hint(value: u64) -> (u32, u32) {
    ((value >> 32) as u32, (value & 0xFFFFFFFF) as u32)
}

fn main(value: Field) {
    let (high, low) = decompose_hint(value as u64);
    // Only constraining the recombination -- but not that high/low are 32-bit
    assert(
        (high as Field) * 4294967296 + (low as Field) == value,
        "decomposition failed"
    );
    // BUG: high could be > u32::MAX if we don't range-check it
    // The recombination check passes with field arithmetic wrapping
}
```

CORRECT:

```noir
unconstrained fn decompose_hint(value: u64) -> (u32, u32) {
    ((value >> 32) as u32, (value & 0xFFFFFFFF) as u32)
}

fn main(value: Field) {
    let (high, low) = decompose_hint(value as u64);
    // Range-check both outputs
    let h = high as u32;  // constrained to 32 bits
    let l = low as u32;   // constrained to 32 bits
    // Verify recombination
    assert(
        (h as Field) * 4294967296 + (l as Field) == value,
        "decomposition failed"
    );
}
```

## Oracle design principles

1. **Minimize oracle surface**: Fewer oracles = fewer trust assumptions
2. **Anchor to public state**: Tie oracle data to a verifiable state root
3. **Make oracle data public when possible**: Public inputs are verified by the smart contract
4. **Version oracle interfaces**: Include a version field so circuits and oracles stay compatible
5. **Fail closed**: If an oracle call fails or returns unexpected data, the circuit should reject the proof
