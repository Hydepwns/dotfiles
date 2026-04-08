---
title: Constrained Circuit Patterns
impact: CRITICAL
impactDescription: Field arithmetic bugs and unnecessary constraints cause unsound proofs or impractical proving times.
tags: noir, constraints, field-arithmetic, optimization
---

# Constrained Circuit Patterns

## Field arithmetic wraps modulo p

Noir operates over a prime field (BN254: p ~ 2^254). Arithmetic wraps silently.
Values that "look" like normal integers can produce unexpected results.

INCORRECT:

```noir
fn check_balance(balance: Field, withdrawal: Field) {
    // BUG: if withdrawal > balance, this wraps modulo p
    // The result is a huge number, not a negative number
    let remaining = balance - withdrawal;
    // This assertion doesn't catch underflow -- remaining is always a valid Field
    assert(remaining != 0, "cannot withdraw everything");
}
```

CORRECT:

```noir
fn check_balance(balance: Field, withdrawal: Field) {
    // Cast to bounded integers for comparison safety
    let b = balance as u64;
    let w = withdrawal as u64;
    assert(b >= w, "insufficient balance");
    let remaining = b - w;
    // Now remaining is genuinely non-negative
}
```

## Minimize constraint count

Every operation in a constrained function adds to the circuit size, which
affects proving time and memory. Reduce constraints by:

1. Moving expensive computation to unconstrained functions
2. Avoiding redundant assertions
3. Using Field arithmetic instead of integer casts when possible

INCORRECT:

```noir
fn verify_membership(leaf: Field, path: [Field; 32], indices: [u1; 32], root: Field) {
    let mut current = leaf;
    for i in 0..32 {
        // Each conditional branch doubles constraints
        if indices[i] == 0 {
            current = std::hash::poseidon::bn254::hash_2([current, path[i]]);
        } else {
            current = std::hash::poseidon::bn254::hash_2([path[i], current]);
        }
    }
    assert(current == root, "invalid merkle proof");
}
```

CORRECT:

```noir
fn verify_membership(leaf: Field, path: [Field; 32], indices: [u1; 32], root: Field) {
    let mut current = leaf;
    for i in 0..32 {
        // Branchless: select ordering via arithmetic
        let idx = indices[i] as Field;
        let left = current + idx * (path[i] - current);
        let right = path[i] + idx * (current - path[i]);
        current = std::hash::poseidon::bn254::hash_2([left, right]);
    }
    assert(current == root, "invalid merkle proof");
}
```

## Witness vs constraint separation

The witness is the prover's private data. Constraints are the public
verification rules. Keep them clearly separated in your mental model.

- **Witness inputs**: Values the prover provides (private inputs, intermediate computations)
- **Constraints**: Mathematical relationships that must hold for the proof to verify
- **Public inputs**: Values both prover and verifier see

INCORRECT:

```noir
// Mixing witness computation and constraint logic
fn main(x: pub Field, secret: Field) {
    let a = secret * secret;
    let b = a + x;
    let c = b * 3;
    // What exactly are we proving? Unclear.
    assert(c == 42, "proof failed");
}
```

CORRECT:

```noir
// Clear separation: what we're proving and why
fn main(
    public_commitment: pub Field,  // verifier checks this
    secret: Field,                  // prover's private witness
) {
    // Witness computation: derive the commitment
    let computed = std::hash::poseidon::bn254::hash_1([secret]);
    // Constraint: commitment matches
    assert(computed == public_commitment, "invalid secret for commitment");
}
```

## Range checks are expensive -- use them deliberately

Each `as u32` or `as u64` cast adds range-check constraints (proportional
to bit width). Only cast when you genuinely need bounded arithmetic.

INCORRECT:

```noir
fn add_values(a: Field, b: Field) -> Field {
    // 128 range-check constraints just to add two numbers
    let result = (a as u64) + (b as u64);
    result as Field
}
```

CORRECT:

```noir
fn add_values(a: Field, b: Field) -> Field {
    // Zero extra constraints -- Field addition is native
    a + b
}

fn add_bounded(a: Field, b: Field, max: u64) -> u64 {
    // Range checks justified: we need the overflow guarantee
    let sum = (a as u64) + (b as u64);
    assert(sum <= max, "sum exceeds maximum");
    sum
}
```
